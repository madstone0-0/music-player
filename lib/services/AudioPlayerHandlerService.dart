/// This service manages the audio player instance and provides methods to manipulate the playback queue and control playback.
/// It also handles logging play history and restoring the last session state.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/repo/history.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initializes the JustAudioBackground service with the appropriate configuration for Android notifications.
Future<void> initAudioService() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.madstone.music_player.channel.audio',
    androidNotificationChannelName: 'music_player',
    androidShowNotificationBadge: true,
    androidStopForegroundOnPause: true,
    notificationColor: Colors.grey[900],
  );
}

/// A custom ShuffleOrder implementation that preserves the shuffle order across playlist modifications.
class FixedShuffleOrder extends ShuffleOrder {
  @override
  final List<int> indices;
  final List<int> _preferredInitialOrder;

  FixedShuffleOrder(List<int> indices)
    : _preferredInitialOrder = List<int>.from(indices),
      indices = List<int>.from(indices);

  @override
  void clear() => indices.clear();

  @override
  void insert(int index, int count) {
    final usePreferredInitialOrder =
        indices.isEmpty &&
        index == 0 &&
        _preferredInitialOrder.length == count &&
        _preferredInitialOrder.toSet().length == count &&
        _preferredInitialOrder.every((i) => i >= 0 && i < count);

    if (usePreferredInitialOrder) {
      indices.addAll(_preferredInitialOrder);
      return;
    }

    // When inserting, we add the new indices at the end of the shuffle order, and then shift any existing indices
    // that are greater than or equal to the insertion point to account for the new items.
    final inserted = List.generate(count, (i) => index + i);
    for (var i = 0; i < indices.length; i++) {
      if (indices[i] >= index) {
        indices[i] += count;
      }
    }
    indices.addAll(inserted);
  }

  @override
  void removeRange(int start, int end) {
    // When removing a range, we remove any indices that fall within the removed range, and then shift any existing
    // indices that are greater than or equal to the end of the removed range to account for the removed items.
    final removedCount = end - start;
    indices.removeWhere((i) => i >= start && i < end);
    for (var i = 0; i < indices.length; i++) {
      if (indices[i] >= end) {
        indices[i] -= removedCount;
      }
    }
  }

  @override
  void shuffle({int? initialIndex}) {
    // The shuffle order is fixed, so we don't actually shuffle the indices. However, we do want to move the initial index
    // to the front of the order if it's provided, so that playback starts from the expected item.
    if (initialIndex == null) return;
    final pos = indices.indexOf(initialIndex);
    if (pos > 0) {
      final curr = indices.removeAt(pos);
      indices.insert(0, curr);
    }
  }
}

class AudioPlayerHandlerService {
  final player = AudioPlayer();

  /// The current effective queue of media items, reflecting the current shuffle order and any modifications.
  final ValueNotifier<List<MediaItem>> Q = ValueNotifier([]);

  /// The currently playing media item, or null if no item is currently active.
  final ValueNotifier<MediaItem?> curr = ValueNotifier(null);
  final historyRepo = getIt<HistoryRepository>();
  int? _lastLoggedTrackId;
  Timer? _pendingLogTimer;
  static const Duration _minPlayForLog = Duration(seconds: 3);

  Stream<Duration> get posS => player.positionStream;

  Stream<Duration> get bufPosS => player.bufferedPositionStream;

  Stream<Duration?> get durS => player.durationStream;

  Stream<PlayerState> get playerSS => player.playerStateStream;

  Stream<bool> get playingS => player.playingStream;

  Stream<LoopMode> get loopS => player.loopModeStream;

  Stream<bool> get shuffleS => player.shuffleModeEnabledStream;

  Stream<int?> get currIdxS => player.currentIndexStream;

  Stream<PlaybackEvent> get playbackES => player.playbackEventStream;

  Stream<bool> get shuffleModeS => player.shuffleModeEnabledStream;

  bool get playing => player.playing;

  Duration get pos => player.position;

  Duration get dur => player.duration ?? Duration.zero;

  LoopMode get loop => player.loopMode;

  bool get shuffle => player.shuffleModeEnabled;

  int? get currIdx => player.currentIndex;

  /// Computes the current effective index in the visible queue (Q) based on the player's current index and shuffle order.
  int? get currEffectiveIdx {
    final raw = player.currentIndex;
    if (raw == null) return null;
    final effective = player.effectiveIndices;
    final idx = effective.indexOf(raw);
    return idx == -1 ? null : idx;
  }

  SharedPreferences? _prefs;

  AudioPlayerHandlerService() {
    _init();
  }

  /// Initializes the service by loading the empty playlist, setting up listeners for player state changes, and preparing to restore the last session state.
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadEmptyPlaylist();
    _listenForDurationChanges();
    _listenForSequenceStateChanges();
    _listenForPlayHistoryLogging();
    _listenForTrackAdvances();
    _listenAndSaveState();
  }

  /// Loads an empty playlist into the audio player to ensure it's in a known state before any operations are performed.
  Future<void> _loadEmptyPlaylist() async {
    try {
      await player.setAudioSources(
        [],
        initialIndex: 0,
        initialPosition: Duration.zero,
        shuffleOrder: DefaultShuffleOrder(),
      );
    } catch (e) {
      debugPrint("AudioPlayerHandlerService: Failed to load empty playlist: $e");
    }
  }

  /// Listens for changes in the duration of the current media item and updates the corresponding item in the queue ([Q])
  /// to reflect the new duration. This ensures that any UI components displaying the queue have the most up-to-date information about each item's duration.
  void _listenForDurationChanges() {
    durS.listen((dur) {
      final current = curr.value;
      if (current == null) return;

      final effectiveIdx = Q.value.indexWhere((item) => item.id == current.id);
      if (effectiveIdx == -1) return;

      final updated = Q.value[effectiveIdx].copyWith(duration: dur);
      final next = List.of(Q.value);
      next[effectiveIdx] = updated;
      Q.value = next;

      if (curr.value?.id == updated.id) {
        curr.value = updated;
      }
    });
  }

  /// Listens for changes in the player's sequence state, which can occur when the queue is modified, shuffle mode is toggled, or the current track changes.
  void _listenForSequenceStateChanges() {
    player.sequenceStateStream.listen((ss) async {
      final sequence = ss.effectiveSequence;
      if (sequence.isEmpty) {
        Q.value = [];
        curr.value = null;
        _cancelPendingLog();
        return;
      }

      final items = sequence.map((src) => src.tag as MediaItem).toList();
      final newCurr = ss.currentSource?.tag as MediaItem?;

      if (newCurr?.id != curr.value?.id) {
        _lastLoggedTrackId = null;
        _cancelPendingLog();
      }

      Q.value = items;
      curr.value = newCurr;
    });
  }

  /// Listens for changes in the player's state to determine when to log play history. When playback starts or resumes,
  /// it schedules a log entry after a minimum play duration. If playback is paused, stopped, or if the track changes
  /// before the minimum duration is reached, it cancels the pending log entry.
  void _listenForPlayHistoryLogging() {
    player.playerStateStream.listen((state) {
      if (state.playing &&
          (state.processingState == ProcessingState.ready || state.processingState == ProcessingState.buffering)) {
        _scheduleLog();
      } else {
        _cancelPendingLog();
      }
    });
  }

  /// Listens for changes in the player's current track (as indicated by the sequence state) to determine when to log play history.
  void _listenForTrackAdvances() {
    player.sequenceStateStream.listen((ss) {
      final newId = (ss.currentSource?.tag as MediaItem?)?.id;
      if (newId == null) return;

      final loggedId = _lastLoggedTrackId?.toString();
      if (newId != loggedId && newId != curr.value?.id) return;

      _scheduleLog();
    });
  }

  /// Schedules a log entry for the currently playing track after a minimum play duration. It checks that the track is still the same
  void _scheduleLog() {
    final idx = player.currentIndex;
    final sequence = player.sequence;
    if (idx == null || idx >= sequence.length) return;

    final currentId = int.tryParse((sequence[idx].tag as MediaItem).id);
    if (currentId == null || currentId == _lastLoggedTrackId) return;

    _cancelPendingLog();
    _pendingLogTimer = Timer(_minPlayForLog, () {
      final nowIdx = player.currentIndex;
      final nowSequence = player.sequence;
      if (nowIdx == null || nowIdx >= nowSequence.length) return;
      final nowId = int.tryParse((nowSequence[nowIdx].tag as MediaItem).id);
      if (nowId != currentId) return;
      if (!player.playing) return;
      final ps = player.processingState;
      if (ps != ProcessingState.ready && ps != ProcessingState.buffering) return;

      _lastLoggedTrackId = currentId;
      historyRepo.addEntry(currentId);
    });
  }

  /// Cancels any pending log entry that was scheduled but has not yet been executed.
  /// This is typically called when playback is paused, stopped, or when the track changes before the minimum play duration is reached.
  void _cancelPendingLog() {
    _pendingLogTimer?.cancel();
    _pendingLogTimer = null;
  }

  /// Listens for changes in the player's current index, position, queue, shuffle mode,
  /// and processing state to save the current session state to shared preferences.
  void _listenAndSaveState() {
    currIdxS.listen((idx) async {
      if (idx == null) return;
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setInt('last_index', idx);
    });

    posS.listen((pos) async {
      if (pos.inSeconds > 0 && pos.inSeconds % 3 == 0) {
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        await prefs.setInt('last_pos_sec', pos.inSeconds);
      }
    });

    Q.addListener(() async {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final ids = Q.value.map((item) => item.id).toList();
      await prefs.setStringList('last_queue_ids', ids);
    });

    shuffleS.listen((enabled) async {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool('shuffle_enabled', enabled);
    });

    player.sequenceStateStream.listen((ss) async {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      if (!ss.shuffleModeEnabled) {
        await prefs.remove('shuffle_order');
        return;
      }

      final effectiveIndices = player.effectiveIndices;
      await prefs.setString('shuffle_order', effectiveIndices.join(','));
    });

    playerSS.listen((state) async {
      if (state.processingState == ProcessingState.completed && !playing) {
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        await prefs.setBool("played_to_end", true);
      }
    });
  }

  /// Restores the last session state from shared preferences, including the last played track, position, queue, and shuffle mode.
  Future<void> restoreLastSession(List<MediaItem> savedQueue) async {
    if (savedQueue.isEmpty) return;

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final lastIndex = prefs.getInt('last_index') ?? 0;
    final lastPosSec = prefs.getInt('last_pos_sec') ?? 0;
    final playedToEnd = prefs.getBool('played_to_end') ?? false;
    final shuffleEnabled = prefs.getBool('shuffle_enabled') ?? false;
    final shuffleOrderRaw = prefs.getString('shuffle_order');

    if (playedToEnd) {
      await prefs.remove('last_index');
      await prefs.remove('last_pos_sec');
      await prefs.remove('last_queue_ids');
      await prefs.remove('shuffle_enabled');
      await prefs.remove('shuffle_order');
      await prefs.remove('played_to_end');
      return;
    }

    final safeIndex = lastIndex < savedQueue.length ? lastIndex : 0;

    List<int>? restoredOrder;
    if (shuffleEnabled && shuffleOrderRaw != null) {
      final parsed = shuffleOrderRaw.split(',').map(int.tryParse).whereType<int>().toList();
      final expected = List.generate(savedQueue.length, (i) => i).toSet();
      if (parsed.toSet().containsAll(expected) && parsed.length == savedQueue.length) {
        restoredOrder = parsed;
      }
    }

    await _rebuildQueuePreservingState(
      rawItems: savedQueue,
      shuffleEnabled: shuffleEnabled,
      shuffleOrderIndices: restoredOrder,
    );

    await player.seek(Duration(seconds: lastPosSec), index: safeIndex);
    await player.pause();
  }

  /// Creates a [UriAudioSource] from a given [MediaItem], using the URL specified in the item's extras.
  UriAudioSource _makeAudioSource(MediaItem itm) =>
      AudioSource.uri(Uri.parse((itm.extras?["url"] as String)), tag: itm);

  /// Creates a list of [UriAudioSource] objects from a list of [MediaItem]s by mapping each item to its corresponding audio source.
  List<UriAudioSource> _makeAudioSources(List<MediaItem> items) => items.map(_makeAudioSource).toList();

  /// Retrieves the raw list of media items from the player's current sequence, without applying any shuffle order or modifications.
  List<MediaItem> _rawQueueItems() {
    return player.sequence.map((src) => src.tag as MediaItem).toList();
  }

  /// Retrieves the current effective indices from the player, which represent the order of items in the visible queue (Q) after applying shuffle and any modifications.
  List<int> _effectiveRawIndices() {
    return List<int>.from(player.effectiveIndices);
  }

  /// Emits a snapshot of the current sequence state to update the visible queue (Q) and the currently active media item (curr).
  void _emitSequenceSnapshot() {
    final state = player.sequenceState;

    final effective = state.effectiveSequence;
    if (effective.isEmpty) {
      Q.value = [];
      curr.value = null;
      return;
    }

    Q.value = effective.map((src) => src.tag as MediaItem).toList();
    curr.value = state.currentSource?.tag as MediaItem?;
  }

  /// Rebuilds the player's queue with a new list of raw media items and an optional shuffle order, while preserving the
  /// current playback state (playing/paused, loop mode, current track and position).
  /// This is used when modifying the queue while shuffle mode is enabled, to ensure that the current track continues playing without
  /// interruption and that the shuffle order is maintained as much as possible.
  Future<void> _rebuildQueuePreservingState({
    required List<MediaItem> rawItems,
    required bool shuffleEnabled,
    List<int>? shuffleOrderIndices,
  }) async {
    final wasPlaying = player.playing;
    final loopMode = player.loopMode;
    final currentId = curr.value?.id;
    final currentPos = player.position;

    // First we determine the initial raw index to set for the player after rebuilding the queue. We want to preserve the currently playing track if possible.
    // If the current track's ID is still present in the new raw items, we use its index as the initial index. Otherwise, we default to 0 or null if the queue is empty.
    // This ensures that if the currently playing track is still in the queue after modifications, it will continue playing without interruption.
    // If it has been removed, we start from the beginning of the new queue.

    int? initialRawIndex;
    if (currentId != null) {
      final idx = rawItems.indexWhere((item) => item.id == currentId);
      if (idx != -1) initialRawIndex = idx;
    }
    initialRawIndex ??= rawItems.isEmpty ? null : 0;

    final shuffleOrder = shuffleOrderIndices != null ? FixedShuffleOrder(shuffleOrderIndices) : DefaultShuffleOrder();

    await player.setAudioSources(
      _makeAudioSources(rawItems),
      initialIndex: initialRawIndex,
      initialPosition: currentPos,
      shuffleOrder: shuffleOrder,
    );

    await player.setLoopMode(loopMode);
    await player.setShuffleModeEnabled(shuffleEnabled);
    _emitSequenceSnapshot();

    if (wasPlaying) {
      await player.play();
    } else {
      await player.pause();
    }
  }

  /// Adds a single [MediaItem] to the end of the queue. If shuffle mode is disabled, it simply appends the new item to the player's audio sources.
  Future<void> addQueueItem(MediaItem item) async {
    if (!player.shuffleModeEnabled) {
      await player.addAudioSource(_makeAudioSource(item));
      return;
    }

    final rawItems = _rawQueueItems()..add(item);
    final order = _effectiveRawIndices()..add(rawItems.length - 1);

    await _rebuildQueuePreservingState(rawItems: rawItems, shuffleEnabled: true, shuffleOrderIndices: order);
  }

  /// Adds a list of [MediaItem]s to the end of the queue. If shuffle mode is disabled, it simply appends the new items to the player's audio sources.
  Future<void> addQueueItems(List<MediaItem> items) async {
    if (items.isEmpty) return;

    if (!player.shuffleModeEnabled) {
      await player.addAudioSources(_makeAudioSources(items));
      return;
    }

    final rawItems = _rawQueueItems();
    final order = _effectiveRawIndices();

    for (final item in items) {
      rawItems.add(item);
      order.add(rawItems.length - 1);
    }

    await _rebuildQueuePreservingState(rawItems: rawItems, shuffleEnabled: true, shuffleOrderIndices: order);
  }

  /// Inserts a single [MediaItem] at a specific effective index in the queue. If shuffle mode is disabled,
  /// it inserts the new item directly at the specified index.
  Future<void> addQueueItemAt(MediaItem item, int effectiveIdx) async {
    final visibleLen = Q.value.length;
    final safeIdx = effectiveIdx.clamp(0, visibleLen);

    if (!player.shuffleModeEnabled) {
      await player.insertAudioSource(safeIdx, _makeAudioSource(item));
      return;
    }

    final rawItems = _rawQueueItems()..add(item);
    final newRawIndex = rawItems.length - 1;
    final order = _effectiveRawIndices()..insert(safeIdx, newRawIndex);

    await _rebuildQueuePreservingState(rawItems: rawItems, shuffleEnabled: true, shuffleOrderIndices: order);
  }

  /// Inserts a list of [MediaItem]s at a specific effective index in the queue. If shuffle mode is disabled,
  /// it inserts the new items directly at the specified index.
  Future<void> addQueueItemsAt(List<MediaItem> items, int effectiveIdx) async {
    if (items.isEmpty) return;

    final visibleLen = Q.value.length;
    final safeIdx = effectiveIdx.clamp(0, visibleLen);

    if (!player.shuffleModeEnabled) {
      await player.insertAudioSources(safeIdx, _makeAudioSources(items));
      return;
    }

    final rawItems = _rawQueueItems();
    final order = _effectiveRawIndices();

    var insertOffset = 0;
    for (final item in items) {
      rawItems.add(item);
      final newRawIndex = rawItems.length - 1;
      order.insert(safeIdx + insertOffset, newRawIndex);
      insertOffset++;
    }

    await _rebuildQueuePreservingState(rawItems: rawItems, shuffleEnabled: true, shuffleOrderIndices: order);
  }

  /// Updates an existing [MediaItem] in the queue by matching its ID. If the item is found,
  /// it replaces it with the new item and rebuilds the queue to reflect the change.
  Future<void> updateMediaItem(MediaItem item) async {
    final rawItems = _rawQueueItems();
    final rawIdx = rawItems.indexWhere((e) => e.id == item.id);
    if (rawIdx == -1) return;

    rawItems[rawIdx] = item;

    await _rebuildQueuePreservingState(
      rawItems: rawItems,
      shuffleEnabled: player.shuffleModeEnabled,
      shuffleOrderIndices: player.shuffleModeEnabled ? _effectiveRawIndices() : null,
    );
  }

  /// Removes a media item from the queue at a specific effective index. If shuffle mode is disabled,
  /// it removes the item directly at the specified index.
  Future<void> removeQueueItemAt(int effectiveIdx) async {
    if (effectiveIdx < 0 || effectiveIdx >= Q.value.length) return;

    if (!player.shuffleModeEnabled) {
      await player.removeAudioSourceAt(effectiveIdx);
      return;
    }

    final rawItems = _rawQueueItems();
    final order = _effectiveRawIndices();
    final rawIdx = order[effectiveIdx];

    rawItems.removeAt(rawIdx);

    final nextOrder = <int>[];
    for (final idx in order) {
      if (idx == rawIdx) continue;
      nextOrder.add(idx > rawIdx ? idx - 1 : idx);
    }

    await _rebuildQueuePreservingState(rawItems: rawItems, shuffleEnabled: true, shuffleOrderIndices: nextOrder);
  }

  /// Moves a media item in the queue from one effective index to another. If shuffle mode is disabled,
  /// it moves the item directly from the source index to the destination index.
  Future<void> moveQueueItem(int fromEffectiveIdx, int toEffectiveIdx) async {
    if (fromEffectiveIdx < 0 || fromEffectiveIdx >= Q.value.length) return;
    if (toEffectiveIdx < 0 || toEffectiveIdx >= Q.value.length) return;

    if (!player.shuffleModeEnabled) {
      await player.moveAudioSource(fromEffectiveIdx, toEffectiveIdx);
      return;
    }

    final rawItems = _rawQueueItems();
    final order = _effectiveRawIndices();

    final movedRawIdx = order.removeAt(fromEffectiveIdx);
    order.insert(toEffectiveIdx, movedRawIdx);

    await _rebuildQueuePreservingState(rawItems: rawItems, shuffleEnabled: true, shuffleOrderIndices: order);
  }

  /// Replaces the entire playlist with a new list of [MediaItem]s and starts playback from a specific effective index. If shuffle mode is disabled,
  /// it sets the new audio sources directly with the specified initial index.
  Future<void> setNewPlaylist(List<MediaItem> items, int idx) async {
    await player.clearAudioSources();
    if (items.isNotEmpty) {
      await player.setAudioSources(_makeAudioSources(items), initialIndex: idx, initialPosition: Duration.zero);
    }
  }

  /// Clears the entire playback queue and stops playback. This is used when the user wants to reset the player to an empty state.
  Future<void> clearQueue() async {
    await player.stop();
    await player.clearAudioSources();
  }

  Future<void> play() => player.play();

  Future<void> pause() => player.pause();

  Future<void> seek(Duration pos) => player.seek(pos);

  Future<void> skipToQueueItem(int effectiveIdx) async {
    if (effectiveIdx < 0 || effectiveIdx >= Q.value.length) return;

    final rawIndex = player.shuffleModeEnabled ? player.effectiveIndices[effectiveIdx] : effectiveIdx;

    await player.seek(Duration.zero, index: rawIndex);
  }

  Future<void> skipToNext() => player.seekToNext();

  Future<void> skipToPrevious() async {
    if (player.position.inSeconds > 3) {
      await player.seek(Duration.zero);
    } else {
      await player.seekToPrevious();
    }
  }

  Future<void> setRepeatMode(LoopMode loopMode) => player.setLoopMode(loopMode);

  Future<void> setShuffleMode(bool enabled) async {
    if (enabled == player.shuffleModeEnabled) return;

    if (enabled) {
      await player.shuffle();
      await player.setShuffleModeEnabled(true);
    } else {
      await player.setShuffleModeEnabled(false);
    }
  }

  Future<void> stop() async {
    await player.stop();
    await player.seek(Duration.zero);
  }

  Future<void> dispose() async {
    await player.dispose();
    Q.dispose();
    curr.dispose();
  }
}
