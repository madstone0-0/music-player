import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/tables/track.dart';
import 'package:music_player/services/AudioTaggingService.dart';
import 'package:music_player/services/LocalMediaService.dart';

import '../db.dart';

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

  Future<List<TrackData>> getAll() => _db.trackDao.getAllTracks();

  Future<TrackData> getById(int id) => _db.trackDao.getTrackById(id);

  Future<List<TrackData>> getByIds(List<int> ids) => _db.trackDao.getTracksByIds(ids);

  Stream<List<TrackData>> watchAll({TrackSortMode mode = TrackSortMode.titleAsc}) => _db.trackDao.watchAllTracks(mode: mode);

  Future<List<TrackData>> getByAlbum(String album, {TrackSortMode mode = TrackSortMode.titleAsc}) async {
    final allTracks = await _db.trackDao.getAllTracks();
    return allTracks.where((t) => t.album == album).toList();
  }

  Stream<List<TrackData>> watchByAlbumAndArtist(String? album, String? artist) => _db.trackDao
      .watchAllTracks(mode: TrackSortMode.trackNoAsc)
      .map((list) => list.where((t) => t.album == album && t.artist == artist).toList());

  Stream<List<Map<String, dynamic>>> watchGroupedAlbums({TrackSortMode mode = TrackSortMode.albumAsc}) =>
      _db.trackDao.watchGroupedAlbums(mode: mode);

  Stream<List<Map<String, dynamic>>> watchGroupedArtists({
    ArtistGrouping grouping = ArtistGrouping.artist,
    TrackSortMode mode = TrackSortMode.artistAsc,
  }) => grouping == ArtistGrouping.artist
      ? _db.trackDao.watchGroupedArtists(mode: mode)
      : _db.trackDao.watchGroupedAlbumArtists(mode: mode);

  Stream<List<TrackData>> watchTracksByArtist(String name, {ArtistGrouping grouping = ArtistGrouping.artist}) =>
      grouping == ArtistGrouping.artist
      ? _db.trackDao.watchTracksByArtist(name)
      : _db.trackDao.watchTracksByAlbumArtist(name);

  Stream<List<Map<String, dynamic>>> watchAlbumsByArtist(
    String name, {
    ArtistGrouping grouping = ArtistGrouping.artist,
  }) => _db.trackDao.watchAlbumsByArtist(name, grouping: grouping);

  Future<TrackData?> findByPath(String path) => _db.trackDao.getTrackByPath(path);

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

  Future<int> updateFromFile({
    required int id,
    required String title,
    String? artist,
    String? album,
    String? genre,
    DateTime? lastModified,
  }) {
    return _db.trackDao.updateTrackMetadata(
      id: id,
      title: title,
      artist: artist,
      album: album,
      genre: genre,
      lastModified: lastModified,
    );
  }

  Future<int> removeByPath(String path) => _db.trackDao.markTrackUnindexedByPath(path);

  Future<int> fullRescan({
    void Function(int current, int total, String path)? onProgress,
    bool overwrite = false,
  }) async {
    final files = await _mediaService.scanAudioFiles();
    final total = files.length;
    if (total == 0) return 0;

    final snapshots = await _db.trackDao.getTrackScanSnapshots();
    final dbMap = <String, DateTime?>{for (final row in snapshots) row.path: row.lastModified};

    final pathsToRead = <String>[];
    final currentPathsOnDisk = <String>{};
    const int batchSize = 100;

    for (int i = 0; i < total; i++) {
      final file = files[i];
      currentPathsOnDisk.add(file.path);

      final dbModified = dbMap[file.path];
      final needsUpdate = overwrite || dbModified == null || dbModified.isBefore(file.modifiedAt);

      if (needsUpdate) {
        pathsToRead.add(file.path);
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

    final pathsMissingFromDisk = dbMap.keys.where((path) => !currentPathsOnDisk.contains(path)).toList();

    if (pathsMissingFromDisk.isNotEmpty) {
      await _db.trackDao.markTracksUnindexedByPaths(pathsMissingFromDisk);
    }

    return total;
  }

  Future<void> _processAndSaveBatch(List<String> paths) async {
    if (paths.isEmpty) return;

    final RootIsolateToken token = RootIsolateToken.instance!;
    final parsedBatch = await compute(_parseMetadataTask, {'paths': paths, 'token': token});

    await _db.trackDao.upsertTracks(parsedBatch);
  }

  Future<List<TrackData>> singleRescan(TrackData track) async {
    final rescanned = await AudioTaggingService.read(track.path);
    await _db.trackDao.upsertTrack(rescanned);
    return _db.trackDao.getAllTracks();
  }
}
