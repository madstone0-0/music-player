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

  final AppDatabase _db;
  final LocalMediaService _mediaService;

  Future<List<TrackData>> getAll() => _db.trackDao.getAllTracks();

  Future<TrackData> getById(int id) => _db.trackDao.getTrackById(id);

  Future<List<TrackData>> getByIds(List<int> ids) => _db.trackDao.getTracksByIds(ids);

  Stream<List<TrackData>> watchAll({SortMode mode = SortMode.titleAsc}) => _db.trackDao.watchAllTracks(mode: mode);

  Future<List<TrackData>> getByAlbum(String album, {SortMode mode = SortMode.titleAsc}) async {
    final allTracks = await _db.trackDao.getAllTracks();
    return allTracks.where((t) => t.album == album).toList();
  }

  Stream<List<TrackData>> watchByAlbum(String album) => _db.trackDao
      .watchAllTracks(mode: SortMode.trackNoAsc)
      .map((list) => list.where((t) => t.album == album).toList());

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

  Future<int> removeByPath(String path) => _db.trackDao.deleteTrackByPath(path);

  Future<int> fullRescan({
    void Function(int current, int total, String path)? onProgress,
    bool overwrite = false,
  }) async {
    final files = await _mediaService.scanAudioFiles();
    final total = files.length;
    if (total == 0) return total;

    final existingTracks = await _db.trackDao.getAllTracks();
    final Map<String, DateTime?> dbMap = {for (var t in existingTracks) t.path: t.lastModified};

    final List<String> pathsToRead = [];
    final List<String> currentPathsOnDisk = [];
    const int batchSize = 50;

    for (int i = 0; i < total; i++) {
      final file = files[i];
      currentPathsOnDisk.add(file.path);

      final fileModified = file.modifiedAt;
      final dbModified = dbMap[file.path];

      final needsUpdate = overwrite || dbModified == null || fileModified.isAfter(dbModified);

      if (needsUpdate) {
        pathsToRead.add(file.path);
      }

      onProgress?.call(i + 1, total, file.path);

      if (pathsToRead.length >= batchSize) {
        await _processAndSaveBatch(pathsToRead);
        pathsToRead.clear();
      }
    }

    if (pathsToRead.isNotEmpty) {
      await _processAndSaveBatch(pathsToRead);
    }

    final pathsToDelete = dbMap.keys.where((path) => !currentPathsOnDisk.contains(path)).toList();

    if (pathsToDelete.isNotEmpty) {
      await (_db.delete(_db.track)..where((t) => t.path.isIn(pathsToDelete))).go();
    }

    return total;
  }

  Future<void> _processAndSaveBatch(List<String> paths) async {
    final RootIsolateToken token = RootIsolateToken.instance!;

    final List<TrackCompanion> parsedBatch = await compute(_parseMetadataTask, {'paths': paths, 'token': token});

    await _db.batch((batch) {
      batch.insertAll(_db.track, parsedBatch, mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<TrackData>> singleRescan(TrackData track) async {
    var tag = await AudioTaggingService.read(track.path);
    await _db.trackDao.upsertTrack(tag);
    return _db.trackDao.getAllTracks();
  }
}
