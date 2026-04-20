/// Defines the QueueIntent class, which represents an intent to add tracks to the queue based on a track, album, or artist.
/// Also defines the QueueActionHandler class, which processes QueueIntents and interacts with the MusicService to add tracks to the queue or play them next.
library;

import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

/// Represents an intent to add tracks to the queue based on a track, album, or artist.
enum QueueIntentKind { track, album, artist }

class QueueIntent {
  /// Creates a QueueIntent to add a single track to the queue.
  QueueIntent.track(this.track)
    : kind = QueueIntentKind.track,
      album = null,
      artist = null,
      grouping = null,
      tracks = null,
      trackCountHint = 1;

  /// Creates a QueueIntent to add all tracks from an album (optionally by a specific artist) to the queue.
  QueueIntent.album({required this.album, this.artist, this.tracks, int? trackCount})
    : kind = QueueIntentKind.album,
      grouping = null,
      track = null,
      trackCountHint = trackCount ?? tracks?.length;

  /// Creates a QueueIntent to add all tracks by an artist (optionally grouped by album) to the queue.
  QueueIntent.artist({required this.artist, required this.grouping, int? trackCount})
    : kind = QueueIntentKind.artist,
      album = null,
      track = null,
      tracks = null,
      trackCountHint = trackCount;

  final QueueIntentKind kind;
  final TrackData? track;
  final String? album;
  final String? artist;
  final ArtistGrouping? grouping;
  final List<TrackData>? tracks;
  final int? trackCountHint;

  /// Resolves the tracks associated with this intent.
  Future<List<TrackData>> resolveTracks(TrackRepository repo) async {
    switch (kind) {
      case QueueIntentKind.track:
        final t = track;
        if (t == null) throw StateError('Track data missing for queue intent.');
        return [t];
      case QueueIntentKind.album:
        final cached = tracks;
        if (cached != null) return cached;

        final albumName = album;
        if (albumName == null) throw ArgumentError('Album is required to queue tracks.');

        return repo.watchByAlbumAndArtist(albumName, artist).first;
      case QueueIntentKind.artist:
        final name = artist;
        if (name == null) throw ArgumentError('Artist name is required to queue tracks.');
        final group = grouping ?? ArtistGrouping.artist;

        return repo.watchTracksByArtist(name, grouping: group).first;
    }
  }
}

class QueueActionHandler {
  QueueActionHandler({MusicService? musicService, TrackRepository? trackRepository})
    : _music = musicService ?? getIt<MusicService>(),
      _trackRepo = trackRepository ?? getIt<TrackRepository>();

  final MusicService _music;
  final TrackRepository _trackRepo;

  /// Adds tracks to the queue based on the provided QueueIntent. If the intent resolves to a single track,
  /// it adds that track directly; if it resolves to multiple tracks, it adds them all to the queue.
  Future<void> addToQueue(QueueIntent intent) async {
    final tracks = await _resolve(intent);
    if (tracks.isEmpty) return;

    if (tracks.length == 1) {
      await _music.addToQueue(tracks.first);
    } else {
      await _music.addAllToQueue(tracks);
    }
  }

  /// Adds tracks to play next based on the provided QueueIntent. If the intent resolves to a single track,
  /// it adds that track to play next; if it resolves to multiple tracks, it adds them all to play next.
  Future<void> playNext(QueueIntent intent) async {
    final tracks = await _resolve(intent);
    if (tracks.isEmpty) return;

    if (tracks.length == 1) {
      await _music.playNext(tracks.first);
    } else {
      await _music.playManyNext(tracks);
    }
  }

  /// Resolves the tracks associated with the given QueueIntent.
  Future<List<TrackData>> _resolve(QueueIntent intent) async {
    final tracks = await intent.resolveTracks(_trackRepo);
    return tracks;
  }
}
