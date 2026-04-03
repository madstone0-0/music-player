import 'dart:collection';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initAudioService() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.madstone.music_player.channel.audio',
    androidNotificationChannelName: 'music_player',
    androidShowNotificationBadge: true,
    androidStopForegroundOnPause: true,
    notificationColor: Colors.grey[900],
  );
}

class FixedShuffleOrder extends ShuffleOrder {
  @override
  final List<int> indices;

  FixedShuffleOrder(List<int> indices) : indices = List<int>.from(indices);

  @override
  void clear() => indices.clear();

  @override
  void insert(int index, int count) {
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
  final ValueNotifier<List<MediaItem>> Q = ValueNotifier([]);
  final ValueNotifier<MediaItem?> curr = ValueNotifier(null);

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

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadEmptyPlaylist();
    _listenForDurationChanges();
    _listenForSequenceStateChanges();
    _listenAndSaveState();
  }

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

  void _listenForSequenceStateChanges() {
    player.sequenceStateStream.listen((ss) {
      final sequence = ss.effectiveSequence;
      if (sequence.isEmpty) {
        Q.value = [];
        curr.value = null;
        return;
      }

      final items = sequence.map((src) => src.tag as MediaItem).toList();
      Q.value = items;
      curr.value = ss.currentSource?.tag as MediaItem?;
    });
  }

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

    playerSS.listen((state) async {
      if (state.processingState == ProcessingState.completed && !playing) {
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        await prefs.setBool("played_to_end", true);
      }
    });
  }

  Future<void> restoreLastSession(List<MediaItem> savedQueue) async {
    if (savedQueue.isEmpty) return;

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final lastIndex = prefs.getInt('last_index') ?? 0;
    final lastPosSec = prefs.getInt('last_pos_sec') ?? 0;
    final playedToEnd = prefs.getBool('played_to_end') ?? false;

    if (playedToEnd) {
      await prefs.remove('last_index');
      await prefs.remove('last_pos_sec');
      await prefs.remove('last_queue_ids');
      await prefs.remove('played_to_end');
      return;
    }

    final safeIndex = lastIndex < savedQueue.length ? lastIndex : 0;

    await setNewPlaylist(savedQueue, safeIndex);
    await player.seek(Duration(seconds: lastPosSec), index: safeIndex);
    await player.pause();
  }

  UriAudioSource _makeAudioSource(MediaItem itm) =>
      AudioSource.uri(Uri.parse((itm.extras?["url"] as String)), tag: itm);

  List<UriAudioSource> _makeAudioSources(List<MediaItem> items) => items.map(_makeAudioSource).toList();

  List<MediaItem> _rawQueueItems() {
    return player.sequence.map((src) => src.tag as MediaItem).toList();
  }

  List<int> _effectiveRawIndices() {
    return List<int>.from(player.effectiveIndices);
  }

  Future<void> _rebuildQueuePreservingState({
    required List<MediaItem> rawItems,
    required bool shuffleEnabled,
    List<int>? shuffleOrderIndices,
  }) async {
    final wasPlaying = player.playing;
    final loopMode = player.loopMode;
    final currentId = curr.value?.id;
    final currentPos = player.position;

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

    if (wasPlaying) {
      await player.play();
    } else {
      await player.pause();
    }
  }

  Future<void> addQueueItem(MediaItem item) async {
    if (!player.shuffleModeEnabled) {
      await player.addAudioSource(_makeAudioSource(item));
      return;
    }

    final rawItems = _rawQueueItems()..add(item);
    final order = _effectiveRawIndices()..add(rawItems.length - 1);

    await _rebuildQueuePreservingState(rawItems: rawItems, shuffleEnabled: true, shuffleOrderIndices: order);
  }

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

  Future<void> setNewPlaylist(List<MediaItem> items, int idx) async {
    await player.clearAudioSources();
    if (items.isNotEmpty) {
      await player.setAudioSources(_makeAudioSources(items), initialIndex: idx, initialPosition: Duration.zero);
    }
  }

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
