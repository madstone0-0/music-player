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
      final idx = currIdx;
      final currQ = Q.value;
      if (idx == null || idx < 0 || idx >= currQ.length) return;

      final updated = currQ[idx].copyWith(duration: dur);
      final next = List.of(currQ);
      next[idx] = updated;
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

  List<UriAudioSource> _makeAudioSources(List<MediaItem> itm) => itm.map((i) => _makeAudioSource(i)).toList();

  Future<void> addQueueItem(MediaItem itm) async {
    await player.addAudioSource(_makeAudioSource(itm));
    Q.value = List.of(Q.value)..add(itm);
  }

  Future<void> addQueueItems(List<MediaItem> itm) async {
    await player.addAudioSources(_makeAudioSources(itm));
    Q.value = List.of(Q.value)..addAll(itm);
  }

  Future<void> addQueueItemAt(MediaItem itm, int idx) async {
    await player.insertAudioSource(idx, _makeAudioSource(itm));
    final updated = List.of(Q.value)..insert(idx, itm);
    Q.value = updated;
  }

  Future<void> updateMediaItem(MediaItem itm) async {
    final idx = Q.value.indexWhere((e) => e.id == itm.id);
    if (idx == -1) return;
    final updated = List.of(Q.value);
    updated[idx] = itm;
    Q.value = updated;
  }

  Future<void> updateQueue(List<MediaItem> itm) async {
    await player.setAudioSources(_makeAudioSources(itm), initialIndex: 0, initialPosition: Duration.zero);
    Q.value = List.of(itm);
  }

  Future<void> removeQueueItemAt(int idx) async {
    await player.removeAudioSourceAt(idx);
    final updated = List.of(Q.value)..removeAt(idx);
    Q.value = updated;
  }

  Future<void> moveQueueItem(int currIdx, int newIdx) async {
    await player.moveAudioSource(currIdx, newIdx);
  }

  Future<void> removeQueueItemIndex(int idx) async {
    await player.removeAudioSourceAt(idx);
    final updated = List.of(Q.value)..removeAt(idx);
    Q.value = updated;
  }

  Future<void> setNewPlaylist(List<MediaItem> itm, int idx) async {
    await player.clearAudioSources();
    Q.value = List.of(itm);
    if (itm.isNotEmpty) {
      await player.setAudioSources(_makeAudioSources(itm), initialIndex: idx, initialPosition: Duration.zero);
    }
  }

  Future<void> play() => player.play();

  Future<void> pause() => player.pause();

  Future<void> seek(Duration pos) => player.seek(pos);

  Future<void> skipToQueueItem(int idx) async {
    if (idx < 0 || idx >= Q.value.length) return;
    final newIdx = player.shuffleModeEnabled ? player.shuffleIndices[idx] : idx;
    await player.seek(Duration.zero, index: newIdx);
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
    await player.setShuffleModeEnabled(enabled);
    if (enabled) {
      await player.shuffle();
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
