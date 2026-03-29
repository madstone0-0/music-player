import 'dart:collection';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> initAudioService() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.madstone.music_player.channel.audio',
    androidNotificationChannelName: 'music_player',
    // androidNotificationIcon: 'drawable/ic_stat_music_note',
    androidShowNotificationBadge: true,
    androidStopForegroundOnPause: true,
    notificationColor: Colors.grey[900],
  );
}

abstract class AudioPlayerHandler {
  Future<void> setNewPlaylist(List<MediaItem> itm, int idx);

  Future<void> moveQueueItem(int currentIndex, int newIndex);

  Future<void> removeQueueItemIndex(int idx);

  Future<void> addQueueItem(MediaItem mediaItem);

  Future<void> addQueueItems(List<MediaItem> mediaItems);

  Future<void> updateMediaItem(MediaItem mediaItem);

  Future<void> updateQueue(List<MediaItem> queue);

  Future<void> removeQueueItemAt(int index);

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> seek(Duration pos);

  Future<void> skipToQueueItem(int idx);

  Future<void> skipToNext();

  Future<void> skipToPrevious();

  Future<void> setRepeatMode(LoopMode loopMode);

  Future<void> setShuffleMode(bool enabled);

  Future<void> dispose();
}

class AudioPlayerHandlerService implements AudioPlayerHandler {
  final player = AudioPlayer();
  final playlist = ConcatenatingAudioSource(children: [], useLazyPreparation: true);
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

  bool get playing => player.playing;

  Duration get pos => player.position;

  Duration get dur => player.duration ?? Duration.zero;

  LoopMode get loop => player.loopMode;

  bool get shuffle => player.shuffleModeEnabled;

  int? get currIdx => player.currentIndex;

  AudioPlayerHandlerService() {
    _loadEmptyPlaylist();
    _listenForDurationChanges();
    _listenForCurrentIdxChanges();
    _listenForSequenceStateChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await player.setAudioSource(playlist);
      await player.setShuffleModeEnabled(false);
    } catch (e) {
      debugPrint("AudioPlayerHandlerService: Failed to load empty playlist: $e");
    }
  }

  void _listenForDurationChanges() {
    durS.listen((dur) {
      var idx = currIdx;
      final currQ = Q.value;
      if (idx == null || currQ.isEmpty || idx >= currQ.length) return;
      if (shuffle) idx = player.shuffleIndices.indexOf(idx);
      final updated = currQ[idx].copyWith(duration: dur);
      currQ[idx] = updated;
      Q.value = List.of(currQ);
      curr.value = updated;
    });
  }

  void _listenForCurrentIdxChanges() {
    currIdxS.listen((idx) {
      final currQ = Q.value;
      if (idx == null || currQ.isEmpty) return;
      final newIdx = shuffle ? player.shuffleIndices.indexOf(idx) : idx;
      if (newIdx < 0 || newIdx > currQ.length) return;
      curr.value = currQ[newIdx];
    });
  }

  void _listenForSequenceStateChanges() {
    player.sequenceStateStream.listen((ss) {
      final s = ss.effectiveSequence;
      if (s.isEmpty) return;
      final itm = s.map((src) => src.tag as MediaItem).toList();
      Q.value = itm;
    });
  }

  UriAudioSource _makeAudioSource(MediaItem itm) =>
      AudioSource.uri(Uri.parse((itm.extras?["url"] as String)), tag: itm);

  List<UriAudioSource> _makeAudioSources(List<MediaItem> itm) => itm.map((i) => _makeAudioSource(i)).toList();

  @override
  Future<void> addQueueItem(MediaItem itm) async {
    await playlist.add(_makeAudioSource(itm));
    Q.value = List.of(Q.value)..add(itm);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> itm) async {
    await playlist.addAll(_makeAudioSources(itm));
    Q.value = List.of(Q.value)..addAll(itm);
  }

  @override
  Future<void> updateMediaItem(MediaItem itm) async {
    final idx = Q.value.indexWhere((e) => e.id == itm.id);
    if (idx == -1) return;
    final updated = List.of(Q.value);
    updated[idx] = itm;
    Q.value = updated;
  }

  @override
  Future<void> updateQueue(List<MediaItem> itm) async {
    await playlist.clear();
    await playlist.addAll(_makeAudioSources(itm));
    Q.value = List.of(itm);
  }

  @override
  Future<void> removeQueueItemAt(int idx) async {
    await playlist.removeAt(idx);
    final updated = List.of(Q.value)..removeAt(idx);
    Q.value = updated;
  }

  @override
  Future<void> moveQueueItem(int currIdx, int newIdx) async {
    await playlist.move(currIdx, newIdx);
  }

  @override
  Future<void> removeQueueItemIndex(int idx) async {
    await playlist.removeAt(idx);
    final updated = List.of(Q.value)..removeAt(idx);
    Q.value = updated;
  }

  @override
  Future<void> setNewPlaylist(List<MediaItem> itm, int idx) async {
    final count = Q.value.length;
    if (count > 0) await playlist.removeRange(0, count);

    await playlist.addAll(_makeAudioSources(itm));
    Q.value = List.of(itm);

    await player.setAudioSource(playlist, initialIndex: idx, initialPosition: Duration.zero);
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration pos) => player.seek(pos);

  @override
  Future<void> skipToQueueItem(int idx) async {
    if (idx < 0 || idx >= Q.value.length) return;
    final newIdx = player.shuffleModeEnabled ? player.shuffleIndices[idx] : idx;
    await player.seek(Duration.zero, index: newIdx);
  }

  @override
  Future<void> skipToNext() => player.seekToNext();

  @override
  Future<void> skipToPrevious() async {
    // Restart the track if more than 3 s in, otherwise go back.
    if (player.position.inSeconds > 3) {
      await player.seek(Duration.zero);
    } else {
      await player.seekToPrevious();
    }
  }

  @override
  Future<void> setRepeatMode(LoopMode loopMode) => player.setLoopMode(loopMode);

  Future<void> toggleRepeatMode() {
    final next = switch (loop) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    return player.setLoopMode(next);
  }

  @override
  Future<void> setShuffleMode(bool enabled) async {
    if (enabled) await player.shuffle();
    await player.setShuffleModeEnabled(enabled);
  }

  Future<void> toggleShuffle() => setShuffleMode(!shuffle);

  @override
  Future<void> stop() async {
    await player.stop();
  }

  @override
  Future<void> dispose() async {
    await player.dispose();
    Q.dispose();
    curr.dispose();
  }
}
