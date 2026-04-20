/// Defines the logic for the playlist addition modal, which allows users to add tracks, albums, or artists to their playlists.
/// This includes resolving track IDs based on the intent and managing the state of the modal during playlist selection and creation.
library;

import 'dart:async';

import 'package:get/get.dart';
import 'package:music_player/db/daos/playlist.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/playlist.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/LocatorService.dart';

/// Represents the type of addition being made to a playlist: a single track, an entire album, or all tracks by an artist.
enum PlaylistAddKind { track, album, artist }

class PlaylistAddIntent {
  /// Creates a PlaylistAddIntent to add a single track to a playlist.
  PlaylistAddIntent.track(this.track)
    : kind = PlaylistAddKind.track,
      album = null,
      artist = null,
      grouping = null,
      tracks = null,
      trackCountHint = 1;

  /// Creates a PlaylistAddIntent to add all tracks from an album (optionally by a specific artist) to a playlist.
  PlaylistAddIntent.album({required this.album, this.artist, this.tracks, int? trackCount})
    : kind = PlaylistAddKind.album,
      grouping = null,
      track = null,
      trackCountHint = trackCount ?? tracks?.length;

  /// Creates a PlaylistAddIntent to add all tracks by an artist (optionally grouped by album) to a playlist.
  PlaylistAddIntent.artist({required this.artist, required this.grouping, int? trackCount})
    : kind = PlaylistAddKind.artist,
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

  /// Resolves the track IDs associated with this intent, which can then be added to a playlist.
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
    _fetch();
  }

  void _fetch() {
    _playlistSub?.cancel();
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

  /// Adds the tracks associated with the intent to the specified playlist. Returns the number of tracks added.
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

  /// Creates a new playlist with the given name and adds the tracks associated with the intent to it.
  /// Returns the ID of the new playlist and the number of tracks added.
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
