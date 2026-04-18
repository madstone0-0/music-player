import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

enum QueueIntentKind { track, album, artist }

class QueueIntent {
  QueueIntent.track(this.track)
      : kind = QueueIntentKind.track,
        album = null,
        artist = null,
        grouping = null,
        tracks = null,
        trackCountHint = 1;

  QueueIntent.album({
    required this.album,
    this.artist,
    this.tracks,
    int? trackCount,
  })  : kind = QueueIntentKind.album,
        grouping = null,
        track = null,
        trackCountHint = trackCount ?? tracks?.length;

  QueueIntent.artist({
    required this.artist,
    required this.grouping,
    int? trackCount,
  })  : kind = QueueIntentKind.artist,
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

  Future<void> addToQueue(QueueIntent intent) async {
    final tracks = await _resolve(intent);
    if (tracks.isEmpty) return;

    if (tracks.length == 1) {
      await _music.addToQueue(tracks.first);
    } else {
      await _music.addAllToQueue(tracks);
    }
  }

  Future<void> playNext(QueueIntent intent) async {
    final tracks = await _resolve(intent);
    if (tracks.isEmpty) return;

    if (tracks.length == 1) {
      await _music.playNext(tracks.first);
    } else {
      await _music.playManyNext(tracks);
    }
  }

  Future<List<TrackData>> _resolve(QueueIntent intent) async {
    final tracks = await intent.resolveTracks(_trackRepo);
    return tracks;
  }
}
