import 'package:drift/drift.dart';
import 'package:music_player/db/db.dart';

import '../tables/track.dart';

part "track.g.dart";

enum TrackSortMode {
  titleAsc,
  titleDesc,
  artistAsc,
  artistDesc,
  albumArtistAsc,
  albumArtistDesc,
  albumAsc,
  albumDesc,
  trackNoAsc,
  trackNoDesc,
  yearAsc,
  yearDesc,
}

enum ArtistGrouping { artist, albumArtist }

class TrackScanSnapshot {
  final String path;
  final DateTime? lastModified;

  TrackScanSnapshot({required this.path, required this.lastModified});
}

class AlbumSearchRow {
  final TrackData album;
  final int? trackCount;

  AlbumSearchRow({required this.album, required this.trackCount});
}

OrderingTerm _order(dynamic t, TrackSortMode mode) {
  switch (mode) {
    case TrackSortMode.titleAsc:
      return OrderingTerm(expression: t.title);
    case TrackSortMode.titleDesc:
      return OrderingTerm(expression: t.title, mode: OrderingMode.desc);
    case TrackSortMode.artistAsc:
      return OrderingTerm(expression: t.artist);
    case TrackSortMode.artistDesc:
      return OrderingTerm(expression: t.artist, mode: OrderingMode.desc);
    case TrackSortMode.albumAsc:
      return OrderingTerm(expression: t.album);
    case TrackSortMode.albumDesc:
      return OrderingTerm(expression: t.album, mode: OrderingMode.desc);
    case TrackSortMode.trackNoAsc:
      return OrderingTerm(expression: t.trackNo);
    case TrackSortMode.trackNoDesc:
      return OrderingTerm(expression: t.trackNo, mode: OrderingMode.desc);
    case TrackSortMode.yearAsc:
      return OrderingTerm(expression: t.year);
    case TrackSortMode.yearDesc:
      return OrderingTerm(expression: t.year, mode: OrderingMode.desc);
    case TrackSortMode.albumArtistAsc:
      return OrderingTerm(expression: t.albumArtist);
    case TrackSortMode.albumArtistDesc:
      return OrderingTerm(expression: t.albumArtist, mode: OrderingMode.desc);
  }
}

@DriftAccessor(tables: [Track])
class TrackDao extends DatabaseAccessor<Db> with _$TrackDaoMixin {
  TrackDao(super.attachedDatabase);

  String _searchPattern(String query) => '%${query.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';

  Expression<bool> _isActive(Track t) => t.isIndexed.equals(true);

  Future<List<TrackData>> getAllTracks() => (select(track)..where((t) => _isActive(t))).get();

  Future<TrackData> getTrackById(int id) => (select(track)..where((t) => t.id.equals(id) & _isActive(t))).getSingle();

  Future<List<TrackData>> getTracksByIds(List<int> ids) =>
      (select(track)..where((t) => t.id.isIn(ids) & _isActive(t))).get();

  Future<List<TrackScanSnapshot>> getTrackScanSnapshots() async {
    final query = selectOnly(track)..addColumns([track.path, track.lastModified]);
    final rows = await query.get();

    return rows
        .map((row) => TrackScanSnapshot(path: row.read(track.path)!, lastModified: row.read(track.lastModified)))
        .toList();
  }

  Future<TrackData?> getTrackByPath(String filePath) {
    return (select(track)..where((t) => t.path.equals(filePath) & _isActive(t))).getSingleOrNull();
  }

  Stream<List<TrackData>> watchAllTracks({TrackSortMode mode = TrackSortMode.titleAsc}) {
    return (select(track)
          ..where((t) => _isActive(t))
          ..orderBy([(t) => _order(t, mode)]))
        .watch();
  }

  Stream<List<Map<String, dynamic>>> watchGroupedAlbums({TrackSortMode mode = TrackSortMode.albumAsc}) {
    final trackCount = track.id.count();

    final query = select(track).addColumns([trackCount])
      ..where(_isActive(track))
      ..groupBy([track.album])
      ..orderBy([_order(track, mode)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final trackData = row.readTable(track);
        final count = row.read(trackCount);
        return {...trackData.toJson(), 'trackCount': count};
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> watchGroupedArtists({TrackSortMode mode = TrackSortMode.artistAsc}) {
    final trackCount = track.id.count();

    final query = select(track).addColumns([trackCount])
      ..where(_isActive(track))
      ..groupBy([track.artist])
      ..orderBy([_order(track, mode)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final trackData = row.readTable(track);
        final count = row.read(trackCount);
        return {...trackData.toJson(), 'trackCount': count};
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> watchGroupedAlbumArtists({TrackSortMode mode = TrackSortMode.artistAsc}) {
    final trackCount = track.id.count();

    final query = select(track).addColumns([trackCount])
      ..where(_isActive(track))
      ..groupBy([track.albumArtist])
      ..orderBy([_order(track, mode)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final trackData = row.readTable(track);
        final count = row.read(trackCount);
        return {...trackData.toJson(), 'trackCount': count};
      }).toList();
    });
  }

  Stream<List<TrackData>> watchTracksByArtist(String name) {
    return (select(track)
          ..where((t) => t.artist.equals(name) & _isActive(t))
          ..orderBy([(t) => _order(t, TrackSortMode.albumAsc)]))
        .watch();
  }

  Stream<List<TrackData>> watchTracksByAlbumArtist(String name) {
    return (select(track)
          ..where((t) => t.albumArtist.equals(name) & _isActive(t))
          ..orderBy([(t) => _order(t, TrackSortMode.albumAsc)]))
        .watch();
  }

  Stream<List<Map<String, dynamic>>> watchAlbumsByArtist(
    String name, {
    ArtistGrouping grouping = ArtistGrouping.artist,
  }) {
    final trackCount = track.id.count();

    final query = select(track).addColumns([trackCount])
      ..where(
        grouping == ArtistGrouping.artist
            ? track.artist.equals(name) & _isActive(track)
            : track.albumArtist.equals(name) & _isActive(track),
      )
      ..groupBy([track.album])
      ..orderBy([OrderingTerm(expression: track.year, mode: OrderingMode.desc)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final trackData = row.readTable(track);
        final count = row.read(trackCount);
        return {...trackData.toJson(), 'trackCount': count};
      }).toList();
    });
  }

  Future<int> insertTrack(TrackCompanion entry) {
    return into(track).insert(entry);
  }

  Future<void> insertManyTracks(List<TrackCompanion> entries) {
    return batch((batch) {
      batch.insertAll(track, entries);
    });
  }

  Future<int> upsertTrack(TrackCompanion entry) {
    return into(track).insert(
      entry,
      onConflict: DoUpdate(
        (old) => TrackCompanion(
          trackNo: entry.trackNo,
          path: entry.path,
          title: entry.title,
          artist: entry.artist,
          albumArtist: entry.albumArtist,
          album: entry.album,
          genre: entry.genre,
          year: entry.year,
          coverPath: entry.coverPath,
          lastModified: entry.lastModified,
          isIndexed: const Value(true),
        ),
        target: [track.path],
      ),
    );
  }

  Future<void> upsertTracks(List<TrackCompanion> entries) async {
    if (entries.isEmpty) return;

    await batch((batch) {
      for (final entry in entries) {
        batch.insert(
          track,
          entry,
          onConflict: DoUpdate(
            (old) => TrackCompanion(
              trackNo: entry.trackNo,
              path: entry.path,
              title: entry.title,
              artist: entry.artist,
              albumArtist: entry.albumArtist,
              album: entry.album,
              genre: entry.genre,
              year: entry.year,
              coverPath: entry.coverPath,
              lastModified: entry.lastModified,
              isIndexed: const Value(true),
            ),
            target: [track.path],
          ),
        );
      }
    });
  }

  Future<int> markTracksUnindexedByPaths(List<String> paths) {
    if (paths.isEmpty) return Future.value(0);

    return (update(track)..where((t) => t.path.isIn(paths))).write(const TrackCompanion(isIndexed: Value(false)));
  }

  Future<int> markTrackUnindexedByPath(String filePath) {
    return (update(track)..where((t) => t.path.equals(filePath))).write(const TrackCompanion(isIndexed: Value(false)));
  }

  Future<int> restoreTrackByPath(String filePath) {
    return (update(track)..where((t) => t.path.equals(filePath))).write(const TrackCompanion(isIndexed: Value(true)));
  }

  Future<int> restoreTracksByPaths(List<String> paths) {
    if (paths.isEmpty) return Future.value(0);

    return (update(track)..where((t) => t.path.isIn(paths))).write(const TrackCompanion(isIndexed: Value(true)));
  }

  Future<List<TrackData>> getUnindexedTracks() {
    return (select(track)..where((t) => t.isIndexed.equals(false))).get();
  }

  Stream<List<TrackData>> watchUnindexedTracks() {
    return (select(track)..where((t) => t.isIndexed.equals(false))).watch();
  }

  Future<int> permanentlyDeleteTrackByPath(String filePath) {
    return (delete(track)..where((t) => t.path.equals(filePath))).go();
  }

  Future<int> permanentlyDeleteUnindexedTracks() {
    return (delete(track)..where((t) => t.isIndexed.equals(false))).go();
  }

  Future<int> deleteAllTracks() {
    return delete(track).go();
  }

  Future<void> refreshAllTracks(List<TrackCompanion> tracks) async {
    return transaction(() async {
      await deleteAllTracks();
      await insertManyTracks(tracks);
    });
  }

  Future<int> updateTrackMetadata({
    required int id,
    required String title,
    String? artist,
    String? album,
    String? albumArtist,
    String? genre,
    int? trackNo,
    int? year,
    DateTime? lastModified,
  }) {
    return (update(track)..where((t) => t.id.equals(id))).write(
      TrackCompanion(
        title: Value(title),
        artist: Value(artist),
        albumArtist: Value(albumArtist),
        album: Value(album),
        genre: Value(genre),
        trackNo: Value(trackNo),
        year: Value(year),
        lastModified: Value(lastModified),
      ),
    );
  }

  Future<List<TrackData>> searchTracks(String query, {int limit = 30}) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return Future.value([]);

    final pattern = _searchPattern(trimmed);

    final trackQuery = select(track)
      ..where(
        (t) =>
            _isActive(t) &
            (t.title.like(pattern) | t.artist.like(pattern) | t.album.like(pattern) | t.albumArtist.like(pattern)),
      )
      ..orderBy([(t) => _order(t, TrackSortMode.titleAsc)])
      ..limit(limit);

    return trackQuery.get();
  }

  Future<List<AlbumSearchRow>> searchAlbums(String query, {int limit = 20}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final pattern = _searchPattern(trimmed);
    final trackCount = track.id.count();

    final albumQuery = select(track).addColumns([trackCount])
      ..where(
        _isActive(track) &
            track.album.isNotNull() &
            (track.album.like(pattern) | track.albumArtist.like(pattern) | track.artist.like(pattern)),
      )
      ..groupBy([track.album, track.albumArtist])
      ..orderBy([OrderingTerm(expression: track.album)])
      ..limit(limit);

    final rows = await albumQuery.get();

    return rows
        .map((row) => AlbumSearchRow(album: row.readTable(track), trackCount: row.read(trackCount)))
        .where((row) => (row.album.album ?? '').trim().isNotEmpty)
        .toList();
  }

  Future<List<Map<String, dynamic>>> searchArtists(
    String query, {
    ArtistGrouping grouping = ArtistGrouping.artist,
    int limit = 20,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final pattern = _searchPattern(trimmed);
    final trackCount = track.id.count();
    final column = grouping == ArtistGrouping.artist ? track.artist : track.albumArtist;

    final artistQuery = select(track).addColumns([trackCount])
      ..where(_isActive(track) & column.isNotNull() & column.like(pattern))
      ..groupBy([column])
      ..orderBy([OrderingTerm(expression: column)])
      ..limit(limit);

    final rows = await artistQuery.get();

    return rows.map((row) {
      final trackData = row.readTable(track);
      final count = row.read(trackCount);
      return {...trackData.toJson(), 'trackCount': count};
    }).toList();
  }
}
