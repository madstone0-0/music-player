import 'package:drift/drift.dart';
import 'package:music_player/db/db.dart';

import '../tables/track.dart';

part "track.g.dart";

/// Sort modes for tracks.
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

/// Grouping options for artists.
enum ArtistGrouping { artist, albumArtist }

/// Snapshot of a track's scan status, used for determining if a track needs to be re-scanned.
class TrackScanSnapshot {
  final String path;
  final DateTime? lastModified;
  final bool isIndexed;

  TrackScanSnapshot({required this.path, required this.lastModified, required this.isIndexed});
}

/// Represents a search result row for albums, containing the album's track data and the count of tracks in that album.
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

  /// Search pattern helper that escapes special characters and wraps the query with wildcards for SQL LIKE operations.
  String _searchPattern(String query) => '%${query.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';

  /// Helper method to filter only active (indexed) tracks.
  Expression<bool> _isActive(Track t) => t.isIndexed.equals(true);

  /// Retrieves all active tracks from the database.
  Future<List<TrackData>> getAllTracks() => (select(track)..where((t) => _isActive(t))).get();

  /// Retrieves a single track by its ID, ensuring it is active (indexed).
  Future<TrackData> getTrackById(int id) => (select(track)..where((t) => t.id.equals(id) & _isActive(t))).getSingle();

  /// Retrieves multiple tracks by their IDs, ensuring they are active (indexed).
  Future<List<TrackData>> getTracksByIds(List<int> ids) =>
      (select(track)..where((t) => t.id.isIn(ids) & _isActive(t))).get();

  /// Retrieves a snapshot of all tracks' scan statuses, including their file paths, last modified timestamps, and whether they are indexed.
  Future<List<TrackScanSnapshot>> getTrackScanSnapshots() async {
    final query = selectOnly(track)..addColumns([track.path, track.lastModified, track.isIndexed]);
    final rows = await query.get();

    return rows
        .map(
          (row) => TrackScanSnapshot(
            path: row.read(track.path)!,
            lastModified: row.read(track.lastModified),
            isIndexed: row.read(track.isIndexed)!,
          ),
        )
        .toList();
  }

  /// Retrieves a single track by its file path, ensuring it is active (indexed). Returns null if no such track exists.
  Future<TrackData?> getTrackByPath(String filePath) {
    return (select(track)..where((t) => t.path.equals(filePath) & _isActive(t))).getSingleOrNull();
  }

  /// Watches all active tracks in the database, emitting updates whenever the underlying data changes.
  /// The results can be sorted based on the provided [TrackSortMode].
  Stream<List<TrackData>> watchAllTracks({TrackSortMode mode = TrackSortMode.titleAsc}) {
    return (select(track)
          ..where((t) => _isActive(t))
          ..orderBy([(t) => _order(t, mode)]))
        .watch();
  }

  /// Watches tracks grouped by album, emitting a list of maps where each map contains the album's track data and the count of tracks in that album.
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

  /// Watches tracks grouped by artist, emitting a list of maps where each map contains the artist's track data and the count of tracks for that artist.
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

  /// Watches tracks grouped by album artist, emitting a list of maps where each map contains the album artist's
  /// track data and the count of tracks for that album artist.
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

  /// Watches tracks by a specific artist, emitting updates whenever the underlying data changes.
  /// The results are sorted by album in ascending order.
  Stream<List<TrackData>> watchTracksByArtist(String name) {
    return (select(track)
          ..where((t) => t.artist.equals(name) & _isActive(t))
          ..orderBy([(t) => _order(t, TrackSortMode.albumAsc)]))
        .watch();
  }

  /// Watches tracks by a specific album artist, emitting updates whenever the underlying data changes.
  Stream<List<TrackData>> watchTracksByAlbumArtist(String name) {
    return (select(track)
          ..where((t) => t.albumArtist.equals(name) & _isActive(t))
          ..orderBy([(t) => _order(t, TrackSortMode.albumAsc)]))
        .watch();
  }

  /// Watches albums by a specific artist or album artist, emitting a list of maps where each map contains
  /// the album's track data and the count of tracks in that album.
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

  /// Inserts a new track into the database. Returns the ID of the inserted track.
  Future<int> insertTrack(TrackCompanion entry) {
    return into(track).insert(entry);
  }

  /// Inserts multiple tracks into the database in a single batch operation.
  Future<void> insertManyTracks(List<TrackCompanion> entries) {
    return batch((batch) {
      batch.insertAll(track, entries);
    });
  }

  /// Inserts or updates a track based on its file path.
  /// If a track with the same path already exists, it will be updated with the new values;
  /// otherwise, a new track will be inserted. Returns the ID of the inserted or updated track.
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

  /// Inserts or updates multiple tracks based on their file paths in a single batch operation.
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

  /// Marks tracks as unindexed based on their file paths. Returns the number of tracks that were updated.
  Future<int> markTracksUnindexedByPaths(List<String> paths) {
    if (paths.isEmpty) return Future.value(0);

    return (update(track)..where((t) => t.path.isIn(paths))).write(const TrackCompanion(isIndexed: Value(false)));
  }

  /// Marks a single track as unindexed based on its file path. Returns the number of tracks that were updated (0 or 1).
  Future<int> markTrackUnindexedByPath(String filePath) {
    return (update(track)..where((t) => t.path.equals(filePath))).write(const TrackCompanion(isIndexed: Value(false)));
  }

  /// Restores tracks as indexed based on their file paths. Returns the number of tracks that were updated.
  Future<int> restoreTrackByPath(String filePath) {
    return (update(track)..where((t) => t.path.equals(filePath))).write(const TrackCompanion(isIndexed: Value(true)));
  }

  /// Restores multiple tracks as indexed based on their file paths. Returns the number of tracks that were updated.
  Future<int> restoreTracksByPaths(List<String> paths) {
    if (paths.isEmpty) return Future.value(0);

    return (update(track)..where((t) => t.path.isIn(paths))).write(const TrackCompanion(isIndexed: Value(true)));
  }

  /// Retrieves all tracks that are marked as unindexed, meaning they are not currently considered active in the library.
  Future<List<TrackData>> getUnindexedTracks() {
    return (select(track)..where((t) => t.isIndexed.equals(false))).get();
  }

  /// Watches all tracks that are marked as unindexed, emitting updates whenever the underlying data changes.
  /// This can be used to monitor tracks that have been removed from the library but not yet permanently deleted.
  Stream<List<TrackData>> watchUnindexedTracks() {
    return (select(track)..where((t) => t.isIndexed.equals(false))).watch();
  }

  /// Permanently deletes tracks from the database based on their file paths. Returns the number of tracks that were deleted.
  Future<int> permanentlyDeleteTrackByPath(String filePath) {
    return (delete(track)..where((t) => t.path.equals(filePath))).go();
  }

  /// Permanently deletes multiple tracks from the database based on their file paths. Returns the number of tracks that were deleted.
  Future<int> permanentlyDeleteUnindexedTracks() {
    return (delete(track)..where((t) => t.isIndexed.equals(false))).go();
  }

  /// Permanently deletes all tracks from the database.
  Future<int> deleteAllTracks() {
    return delete(track).go();
  }

  /// Refreshes the entire track library by deleting all existing tracks and inserting a new list of tracks in a single transaction.
  Future<void> refreshAllTracks(List<TrackCompanion> tracks) async {
    return transaction(() async {
      await deleteAllTracks();
      await insertManyTracks(tracks);
    });
  }

  /// Updates the metadata of a track based on its ID. Returns the number of tracks that were updated (0 or 1).
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

  /// Searches for tracks that match the given query in their title, artist, album, or album artist fields.
  /// The search is case-insensitive and supports partial matches. Returns a list of matching tracks, limited to the specified number of results.
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

  /// Searches for artists that match the given query in their artist or album artist fields, depending on the specified grouping.
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
