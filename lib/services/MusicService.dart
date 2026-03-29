import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/db/tables/track_mapper.dart';
import 'package:music_player/services/AudioPlayerHandlerService.dart';
import 'package:music_player/services/LocatorService.dart';

import 'dart:async';
import 'dart:io';

import 'package:music_player/services/PageManagerService.dart';

class MusicService {
  final repo = getIt<TrackRepository>();
  final AudioPlayerHandlerService handler = getIt<AudioPlayerHandlerService>();
  final PageManagerService page = getIt<PageManagerService>();

  Timer? _debounce;
  static const _debounceMs = 600;

  void playDebounced(List<TrackData> tracks, int index, {bool shuffle = false}) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: _debounceMs), () {
      play(tracks, index: index, shuffle: shuffle);
    });
  }

  Future<void> play(List<TrackData> tracks, {int index = 0, bool shuffle = false, bool fromMiniPlayer = false}) async {
    if (fromMiniPlayer) return;

    final int safeIndex = index.clamp(0, tracks.isEmpty ? 0 : tracks.length - 1);
    final List<MediaItem> Q = tracks.map((t) => t.toMediaItem()).toList();
    if (shuffle) Q.shuffle();

    page.setShuffle(false); // reset shuffle state in PageManager
    await handler.setNewPlaylist(Q, safeIndex);
    await handler.play();
  }

  Future<void> playOne(TrackData track) async => play([track], index: 0);

  Future<void> addToQueue(TrackData track) async => await handler.addQueueItem(track.toMediaItem());

  Future<void> playNext(TrackData track) async => await handler.skipToNext();

  // Future<void> updateTag(
  //     TrackData track, {
  //       String? title,
  //       String? artist,
  //       String? album,
  //       String? genre,
  //     }) async {
  //   // 4a. Persist to Drift.
  //   await db.trackDao.updateTag(
  //     track.id,
  //     title:  title,
  //     artist: artist,
  //     album:  album,
  //     genre:  genre,
  //   );
  //
  //   // 4b. Build an updated MediaItem and push it to the live handler
  //   //     so the notification / lock-screen reflects the new tags immediately.
  //   final updated = track
  //       .toMediaItem()
  //       .copyWith(
  //     title:  title  ?? track.title,
  //     artist: artist ?? track.artist,
  //     album:  album  ?? track.album,
  //     genre:  genre  ?? track.genre,
  //   );
  //
  //   await handler.updateMediaItem(updated);
  // }

  // Future<void> playPlaylist(int playlistId, {int startIndex = 0}) async {
  //   final tracks = await db.playlistDao.getTracksForPlaylist(playlistId);
  //   await playAll(tracks, startIndex: startIndex);
  // }

  Future<TrackData?> resolveCurrentTrack() async {
    final track = handler.curr.value;
    if (track == null) return null;
    return repo.getById(int.parse(track.id));
  }

  Future<void> syncQueueWithDb() async {
    final live = handler.Q.value;
    if (live.isEmpty) return;

    final ids = live.map((t) => t.id).toList();
    final freshTracks = await repo.getByIds(ids.map((id) => int.parse(id)).toList());
    final idToTrack = {for (final t in freshTracks) t.id: t};

    final refreshed = ids
        .where(idToTrack.containsKey)
        .map(int.parse)
        .map((id) => idToTrack[id]!)
        .map((t) => t.toMediaItem())
        .toList();

    await handler.updateQueue(refreshed);
  }

  void cancelDebounce() => _debounce?.cancel();
}
