import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/services/AudioTaggingService.dart';
import 'package:music_player/services/LocalMediaService.dart';

import '../db.dart';

/// Parses metadata for a batch of file paths in a background isolate.
Future<List<TrackCompanion>> _parseMetadataTask(Map<String, dynamic> args) async {
  final List<String> paths = args['paths'];
  final RootIsolateToken token = args['token'];

  BackgroundIsolateBinaryMessenger.ensureInitialized(token);

  final List<TrackCompanion> results = [];
  for (final path in paths) {
    final tag = await AudioTaggingService.read(path);
    results.add(tag);
  }
  return results;
}

class TrackRepository {
  TrackRepository(this._db, this._mediaService);

  final Db _db;
  final LocalMediaService _mediaService;

  /// Retrieves all tracks from the database.
  Future<List<TrackData>> getAll() => _db.trackDao.getAllTracks();

  /// Retrieves a track by its ID.
  Future<TrackData> getById(int id) => _db.trackDao.getTrackById(id);

  /// Retrieves multiple tracks by their IDs.
  Future<List<TrackData>> getByIds(List<int> ids) => _db.trackDao.getTracksByIds(ids);

  /// Watches all tracks in the database, emitting updates whenever the track list changes.
  Stream<List<TrackData>> watchAll({TrackSortMode mode = TrackSortMode.titleAsc}) =>
      _db.trackDao.watchAllTracks(mode: mode);

  /// Retrieves all tracks that belong to a specific album.
  Future<List<TrackData>> getByAlbum(String album, {TrackSortMode mode = TrackSortMode.titleAsc}) async {
    final allTracks = await _db.trackDao.getAllTracks();
    return allTracks.where((t) => t.album == album).toList();
  }

  /// Retrieves all tracks that belong to a specific artist.
  Stream<List<TrackData>> watchByAlbumAndArtist(String? album, String? artist) => _db.trackDao
      .watchAllTracks(mode: TrackSortMode.trackNoAsc)
      .map((list) => list.where((t) => t.album == album && t.artist == artist).toList());

  /// Watches grouped albums, emitting updates whenever the grouping changes.
  Stream<List<Map<String, dynamic>>> watchGroupedAlbums({TrackSortMode mode = TrackSortMode.albumAsc}) =>
      _db.trackDao.watchGroupedAlbums(mode: mode);

  /// Watches grouped artists, emitting updates whenever the grouping changes.
  Stream<List<Map<String, dynamic>>> watchGroupedArtists({
    ArtistGrouping grouping = ArtistGrouping.artist,
    TrackSortMode mode = TrackSortMode.artistAsc,
  }) => grouping == ArtistGrouping.artist
      ? _db.trackDao.watchGroupedArtists(mode: mode)
      : _db.trackDao.watchGroupedAlbumArtists(mode: mode);

  /// Watches tracks by a specific artist, emitting updates whenever the track list changes.
  Stream<List<TrackData>> watchTracksByArtist(String name, {ArtistGrouping grouping = ArtistGrouping.artist}) =>
      grouping == ArtistGrouping.artist
      ? _db.trackDao.watchTracksByArtist(name)
      : _db.trackDao.watchTracksByAlbumArtist(name);

  /// Watches albums by a specific artist, emitting updates whenever the album list changes.
  Stream<List<Map<String, dynamic>>> watchAlbumsByArtist(
    String name, {
    ArtistGrouping grouping = ArtistGrouping.artist,
  }) => _db.trackDao.watchAlbumsByArtist(name, grouping: grouping);

  /// Searches for tracks that match the given query, returning a list of matching tracks.
  Future<List<TrackData>> searchTracks(String query, {int limit = 30}) =>
      _db.trackDao.searchTracks(query, limit: limit);

  /// Searches for albums that match the given query, returning a list of matching albums.
  Future<List<AlbumSearchRow>> searchAlbums(String query, {int limit = 30}) =>
      _db.trackDao.searchAlbums(query, limit: limit);

  /// Searches for artists that match the given query, returning a list of matching artists.
  Future<List<Map<String, dynamic>>> searchArtists(
    String query, {
    ArtistGrouping grouping = ArtistGrouping.artist,
    int limit = 30,
  }) => _db.trackDao.searchArtists(query, grouping: grouping, limit: limit);

  /// Finds a track by its file path, returning the track data if found or null if not found.
  Future<TrackData?> findByPath(String path) => _db.trackDao.getTrackByPath(path);

  /// Saves a new track to the database with the provided metadata, returning the ID of the saved track.
  Future<int> save({
    required String path,
    required String title,
    String? artist,
    String? album,
    String? genre,
    DateTime? lastModified,
  }) {
    return _db.trackDao.upsertTrack(
      TrackCompanion.insert(
        path: path,
        title: title,
        artist: Value(artist),
        album: Value(album),
        genre: Value(genre),
        lastModified: Value(lastModified),
      ),
    );
  }

  /// Updates an existing track's metadata in the database, returning the number of rows affected.
  Future<int> updateFromFile({
    required int id,
    required String title,
    String? artist,
    String? albumArtist,
    String? album,
    String? genre,
    int? trackNo,
    int? year,
    DateTime? lastModified,
  }) {
    return _db.trackDao.updateTrackMetadata(
      id: id,
      title: title,
      artist: artist,
      albumArtist: albumArtist,
      album: album,
      genre: genre,
      trackNo: trackNo,
      year: year,
      lastModified: lastModified,
    );
  }

  /// Marks a track as unindexed in the database based on its file path, returning the number of rows affected.
  Future<int> removeByPath(String path) => _db.trackDao.markTrackUnindexedByPath(path);

  /// Performs a full rescan of the media library, updating the database with any changes to the audio files on disk.
  /// The [onProgress] callback is called with the current progress of the rescan, including the current file being processed.
  /// If [overwrite] is true, all tracks will be re-read from disk and updated in the database, even if they haven't changed.
  /// Returns the total number of audio files found during the rescan.
  Future<int> fullRescan({
    void Function(int current, int total, String path)? onProgress,
    bool overwrite = false,
  }) async {
    final files = await _mediaService.scanAudioFiles();
    final total = files.length;
    if (total == 0) return 0;

    final snapshots = await _db.trackDao.getTrackScanSnapshots();
    final dbMap = <String, TrackScanSnapshot>{for (final row in snapshots) row.path: row};

    final pathsToRead = <String>[];
    final pathsToRestore = <String>[];
    final currentPathsOnDisk = <String>{};
    const int batchSize = 100;

    for (int i = 0; i < total; i++) {
      final file = files[i];
      currentPathsOnDisk.add(file.path);

      final snapshot = dbMap[file.path];
      final dbModified = snapshot?.lastModified;
      final needsUpdate = overwrite || dbModified == null || dbModified.isBefore(file.modifiedAt);

      if (needsUpdate) {
        pathsToRead.add(file.path);
      } else if (snapshot != null && !snapshot.isIndexed) {
        pathsToRestore.add(file.path);
      }

      onProgress?.call(i + 1, total, file.path);

      if (pathsToRead.length >= batchSize) {
        await _processAndSaveBatch(List<String>.from(pathsToRead));
        pathsToRead.clear();
      }
    }

    if (pathsToRead.isNotEmpty) {
      await _processAndSaveBatch(List<String>.from(pathsToRead));
    }

    if (pathsToRestore.isNotEmpty) {
      await _db.trackDao.restoreTracksByPaths(pathsToRestore);
    }

    final pathsMissingFromDisk = dbMap.keys.where((path) => !currentPathsOnDisk.contains(path)).toList();

    if (pathsMissingFromDisk.isNotEmpty) {
      await _db.trackDao.markTracksUnindexedByPaths(pathsMissingFromDisk);
    }

    return total;
  }

  /// Helper method to process a batch of file paths, read their metadata in a background isolate, and save the results to the database.
  Future<void> _processAndSaveBatch(List<String> paths) async {
    if (paths.isEmpty) return;

    final RootIsolateToken token = RootIsolateToken.instance!;
    final parsedBatch = await compute(_parseMetadataTask, {'paths': paths, 'token': token});

    await _db.trackDao.upsertTracks(parsedBatch);
  }

  /// Performs a rescan of a single track, updating its metadata in the database based on the current state of the file on disk.
  Future<List<TrackData>> singleRescan(TrackData track) async {
    final rescanned = await AudioTaggingService.read(track.path);
    await _db.trackDao.upsertTrack(rescanned);
    return _db.trackDao.getAllTracks();
  }
}
