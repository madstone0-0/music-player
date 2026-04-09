import 'dart:async';

import 'package:get/get.dart';
import 'package:music_player/db/daos/playlist.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/playlist.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/LocatorService.dart';

enum PlaylistAddKind { track, album, artist }

class PlaylistAddIntent {
  PlaylistAddIntent.track(this.track)
      : kind = PlaylistAddKind.track,
        album = null,
        artist = null,
        grouping = null,
        tracks = null,
        trackCountHint = 1;

  PlaylistAddIntent.album({
    required this.album,
    this.artist,
    this.tracks,
    int? trackCount,
  })  : kind = PlaylistAddKind.album,
        grouping = null,
        track = null,
        trackCountHint = trackCount ?? tracks?.length;

  PlaylistAddIntent.artist({
    required this.artist,
    required this.grouping,
    int? trackCount,
  })  : kind = PlaylistAddKind.artist,
        album = null,
        track = null,
        tracks = null,
        trackCountHint = trackCount;

  final PlaylistAddKind kind;
  final TrackData? track;
  final String? album;
  final String? artist;
  final ArtistGrouping? grouping;
  final List<TrackData>? tracks;
  final int? trackCountHint;

  String get label {
    switch (kind) {
      case PlaylistAddKind.track:
        return track?.title ?? 'Track';
      case PlaylistAddKind.album:
        return album ?? 'Album';
      case PlaylistAddKind.artist:
        return artist ?? 'Artist';
    }
  }

  String? get subtitle {
    switch (kind) {
      case PlaylistAddKind.track:
        return track?.artist;
      case PlaylistAddKind.album:
        return artist;
      case PlaylistAddKind.artist:
        return grouping == ArtistGrouping.albumArtist ? 'Album Artist' : 'Artist';
    }
  }

  Future<List<int>> resolveTrackIds(TrackRepository repo) async {
    switch (kind) {
      case PlaylistAddKind.track:
        final id = track?.id;
        if (id == null) throw StateError('Track data missing.');
        return [id];
      case PlaylistAddKind.album:
        final cached = tracks;
        if (cached != null) return cached.map((t) => t.id).toList();

        final albumName = album;
        if (albumName == null) throw ArgumentError('Album is required to add tracks.');

        final resolved = await repo.watchByAlbumAndArtist(albumName, artist).first;
        return resolved.map((t) => t.id).toList();
      case PlaylistAddKind.artist:
        final name = artist;
        if (name == null) throw ArgumentError('Artist name is required.');
        final group = grouping ?? ArtistGrouping.artist;

        final resolved = await repo.watchTracksByArtist(name, grouping: group).first;
        return resolved.map((t) => t.id).toList();
    }
  }
}

class PlaylistModalViewModel extends GetxController {
  PlaylistModalViewModel({required this.intent});

  final PlaylistAddIntent intent;
  final playlistRepo = getIt<PlaylistRepository>();
  final trackRepo = getIt<TrackRepository>();

  final playlists = <PlaylistWithCount>[].obs;
  final isCreating = false.obs;
  final processingId = RxnInt();

  StreamSubscription<List<PlaylistWithCount>>? _playlistSub;

  @override
  void onInit() {
    super.onInit();
    _playlistSub = playlistRepo.watchPlaylistsWithTrackCounts().listen((items) => playlists.assignAll(items));
  }

  @override
  void onClose() {
    _playlistSub?.cancel();
    super.onClose();
  }

  String get headline {
    switch (intent.kind) {
      case PlaylistAddKind.track:
        return 'Add to playlist';
      case PlaylistAddKind.album:
        return 'Add album to playlist';
      case PlaylistAddKind.artist:
        return 'Add artist to playlist';
    }
  }

  String get description {
    final hint = intent.trackCountHint;
    final base = intent.label;
    switch (intent.kind) {
      case PlaylistAddKind.track:
        return 'Choose a playlist for "$base"';
      case PlaylistAddKind.album:
        final count = hint != null ? ' · ${hint} track${hint == 1 ? '' : 's'}' : '';
        return 'Add album "$base"$count';
      case PlaylistAddKind.artist:
        final qualifier = intent.grouping == ArtistGrouping.albumArtist ? 'album artist' : 'artist';
        final count = hint != null ? ' · ${hint} track${hint == 1 ? '' : 's'}' : '';
        return 'Add $qualifier "$base"$count';
    }
  }

  Future<int> addToPlaylist(int playlistId) async {
    processingId.value = playlistId;
    try {
      final trackIds = await intent.resolveTrackIds(trackRepo);
      if (trackIds.isEmpty) throw StateError('No tracks to add.');

      if (trackIds.length == 1) {
        await playlistRepo.addTrackToPlaylist(playlistId, trackIds.first);
      } else {
        await playlistRepo.addTracksToPlaylist(playlistId, trackIds);
      }

      return trackIds.length;
    } finally {
      processingId.value = null;
    }
  }

  Future<(int playlistId, int addedCount)> createAndAdd(String name) async {
    isCreating.value = true;
    try {
      final playlistId = await playlistRepo.createPlaylist(name.trim());
      final added = await addToPlaylist(playlistId);
      return (playlistId, added);
    } finally {
      isCreating.value = false;
    }
  }
}
