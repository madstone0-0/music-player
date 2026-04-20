/// This service acts as a bridge between the UI and the underlying audio player handler.
/// It provides convenient methods for common playback actions and manages the synchronization of the player's queue with the database.
library;

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/services/AudioPlayerHandlerService.dart';
import 'package:music_player/services/LocatorService.dart';

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class MusicService {
  final repo = getIt<TrackRepository>();
  final AudioPlayerHandlerService handler = getIt<AudioPlayerHandlerService>();

  ValueNotifier<List<MediaItem>> get Q => handler.Q;

  ValueNotifier<MediaItem?> get curr => handler.curr;

  int? get currIdx => handler.currIdx;

  int? get currEffIdx => handler.currEffectiveIdx;

  Stream<PlayerState> get playerSS => handler.playerSS;

  Stream<Duration> get posS => handler.posS;

  Stream<Duration> get bufPosS => handler.bufPosS;

  Stream<Duration?> get durS => handler.durS;

  Stream<bool> get shuffleModeS => handler.shuffleModeS;

  void play() => handler.play();

  void pause() => handler.pause();

  void seek(Duration position) => handler.seek(position);

  void next() => handler.skipToNext();

  void prev() => handler.skipToPrevious();

  void skipTo(int index) => handler.skipToQueueItem(index);

  void setRepeatMode(LoopMode mode) => handler.setRepeatMode(mode);

  void setShuffleMode(bool enabled) => handler.setShuffleMode(enabled);

  Future<void> stop() async => await handler.stop();

  /// Plays a list of tracks starting from a specified index. It can also shuffle the playlist if needed.
  Future<void> playAll(
    List<TrackData> tracks, {
    int index = 0,
    bool shuffle = false,
    bool fromMiniPlayer = false,
  }) async {
    if (fromMiniPlayer) return;
    if (tracks.isEmpty) return;

    final int safeIndex = index.clamp(0, tracks.length - 1);
    final List<MediaItem> q = tracks.map((t) => t.toMediaItem()).toList();

    if (shuffle) {
      await handler.setShuffleMode(false);
      await handler.setNewPlaylist(q, safeIndex);
      await handler.setShuffleMode(true);
    } else {
      await handler.setShuffleMode(false);
      await handler.setNewPlaylist(q, safeIndex);
    }

    await handler.play();
  }

  /// Plays a single track by creating a playlist with just that track and starting playback from it.
  Future<void> playOne(TrackData track) async => playAll([track], index: 0);

  Future<void> addToQueue(TrackData track) async => await handler.addQueueItem(track.toMediaItem());

  Future<void> addAllToQueue(List<TrackData> tracks) async {
    if (tracks.isEmpty) return;
    await handler.addQueueItems(tracks.map((t) => t.toMediaItem()).toList());
  }

  Future<void> removeFromQueue(int index) async => await handler.removeQueueItemAt(index);

  /// Inserts a track immediately after the currently playing track in the queue.
  /// If no track is currently playing, it adds it to the start of the queue.
  Future<void> playNext(TrackData track) async {
    final effIdx = handler.currEffectiveIdx;
    final idx = (effIdx ?? -1) + 1;
    await handler.addQueueItemAt(track.toMediaItem(), idx);
  }

  /// Inserts multiple tracks immediately after the currently playing track in the queue.
  Future<void> playManyNext(List<TrackData> tracks) async {
    if (tracks.isEmpty) return;
    final effIdx = handler.currEffectiveIdx;
    final idx = (effIdx ?? -1) + 1;
    await handler.addQueueItemsAt(tracks.map((t) => t.toMediaItem()).toList(), idx);
  }

  Future<void> clearQueue() async {
    await handler.clearQueue();
  }

  Future<void> moveQueueItem(int from, int to) async => await handler.moveQueueItem(from, to);

  /// Synchronizes the player's queue with the latest data from the database.
  /// It checks if the tracks in the queue still exist in the database and updates their metadata if necessary.
  Future<void> syncQueueWithDb() async {
    final snapshot = handler.Q.value;
    if (snapshot.isEmpty) return;

    final idPairs = snapshot
        .map((item) {
          final id = int.tryParse(item.id);
          return id != null ? (item: item, id: id) : null;
        })
        .whereType<({MediaItem item, int id})>()
        .toList();

    if (idPairs.isEmpty) return;

    final freshTracks = await repo.getByIds(idPairs.map((p) => p.id).toList());
    final idToTrack = {for (final t in freshTracks) t.id: t};

    if (!_listEquals(handler.Q.value.map((e) => e.id).toList(), snapshot.map((e) => e.id).toList())) {
      return;
    }

    for (final pair in idPairs) {
      final fresh = idToTrack[pair.id];
      if (fresh == null) continue;
      await handler.updateMediaItem(fresh.toMediaItem());
    }
  }

  /// Restores the last playback session by retrieving the saved queue from shared preferences,
  /// fetching the corresponding tracks from the database, and then restoring the player's queue with those tracks.
  Future<void> restoreLastSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList('last_queue_ids') ?? [];

    if (savedIds.isEmpty) return;

    final intIds = savedIds.map(int.tryParse).whereType<int>().toList();
    if (intIds.isEmpty) return;

    final tracks = await repo.getByIds(intIds);
    final trackMap = {for (var t in tracks) t.id.toString(): t};

    final restoredItems = savedIds.where(trackMap.containsKey).map((id) => trackMap[id]!.toMediaItem()).toList();

    if (restoredItems.length != savedIds.length) {
      debugPrint(
        'MusicService.restoreLastSession: ${savedIds.length - restoredItems.length} '
        'track(s) could not be restored (deleted from DB). '
        'Playback will resume from the clamped index.',
      );
    }

    await handler.restoreLastSession(restoredItems);
  }

  /// A helper method to compare two lists of strings for equality, used to check if the queue has changed before syncing with the database.
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
