import 'package:drift/drift.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/tables/playlist.dart';
import 'package:music_player/db/tables/track.dart';

part "playlist.g.dart";

/// Sort modes for playlists.
enum PlaylistSortMode { nameAsc, nameDesc, createdAtAsc, createdAtDesc, updatedAtAsc, updatedAtDesc }

OrderingTerm _order(dynamic t, PlaylistSortMode mode) {
  switch (mode) {
    case PlaylistSortMode.nameAsc:
      return OrderingTerm(expression: t.name);
    case PlaylistSortMode.nameDesc:
      return OrderingTerm(expression: t.name, mode: OrderingMode.desc);
    case PlaylistSortMode.createdAtAsc:
      return OrderingTerm(expression: t.createdAt);
    case PlaylistSortMode.createdAtDesc:
      return OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc);
    case PlaylistSortMode.updatedAtAsc:
      return OrderingTerm(expression: t.updatedAt);
    case PlaylistSortMode.updatedAtDesc:
      return OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc);
  }
}

/// A playlist along with the count of tracks it contains.
class PlaylistWithCount {
  PlaylistWithCount({required this.playlist, required this.trackCount});

  final PlaylistData playlist;
  final int trackCount;
}

/// A playlist entry along with its associated track data.
class PlaylistEntryWithTrack {
  PlaylistEntryWithTrack({required this.entry, required this.track});

  final PlaylistEntryData entry;
  final TrackData track;
}

@DriftAccessor(tables: [Playlist, PlaylistEntry, Track])
class PlaylistDao extends DatabaseAccessor<Db> with _$PlaylistDaoMixin {
  PlaylistDao(super.attachedDatabase);

  /// Updates the `updatedAt` timestamp of a playlist to the current time.
  Future<void> modifyPlaylist(int playlistId) {
    return (update(
      playlist,
    )..where((p) => p.id.equals(playlistId))).write(PlaylistCompanion(updatedAt: Value(DateTime.now())));
  }

  /// Creates a new playlist with the given name and returns its ID.
  Future<int> createPlaylist(PlaylistCompanion entry) {
    return into(playlist).insert(entry);
  }

  /// Updates a playlist by its ID with the provided entry data.
  Future<int> updatePlaylistById(int id, PlaylistCompanion entry) {
    return (update(playlist)..where((p) => p.id.equals(id))).write(entry);
  }

  /// Deletes a playlist by its ID and returns the number of rows affected.
  Future<int> deletePlaylistById(int id) {
    return (delete(playlist)..where((p) => p.id.equals(id))).go();
  }

  /// Retrieves all playlists sorted by the specified mode.
  Future<List<PlaylistData>> getAllPlaylists({PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc}) {
    return (select(playlist)..orderBy([(p) => _order(p, mode)])).get();
  }

  /// Watches all playlists sorted by the specified mode and emits updates whenever the data changes.
  Stream<List<PlaylistData>> watchAllPlaylists({PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc}) {
    return (select(playlist)..orderBy([(p) => _order(p, mode)])).watch();
  }

  /// Retrieves a single playlist by its ID, or null if it doesn't exist.
  Future<PlaylistData?> getPlaylistById(int id) {
    return (select(playlist)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Retrieves a single playlist by its name, or null if it doesn't exist.
  Future<PlaylistData?> getPlaylistByName(String name) {
    return (select(playlist)..where((p) => p.name.equals(name))).getSingleOrNull();
  }

  /// Retrieves all playlists along with the count of tracks they contain, sorted by the specified mode.
  Future<List<PlaylistWithCount>> getPlaylistsWithTrackCounts({
    PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc,
  }) async {
    final countExp = playlistEntry.id.count();
    final query = select(playlist).join([leftOuterJoin(playlistEntry, playlistEntry.playlistId.equalsExp(playlist.id))])
      ..addColumns([countExp])
      ..groupBy([playlist.id])
      ..orderBy([_order(playlist, mode)]);

    final rows = await query.get();

    return rows.map((row) {
      final p = row.readTable(playlist);
      final count = row.read(countExp) ?? 0;
      return PlaylistWithCount(playlist: p, trackCount: count);
    }).toList();
  }

  /// Watches all playlists along with the count of tracks they contain, sorted by the specified mode,
  /// and emits updates whenever the data changes.
  Stream<List<PlaylistWithCount>> watchPlaylistsWithTrackCounts({
    PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc,
  }) {
    final countExp = playlistEntry.id.count();
    final query = select(playlist).join([leftOuterJoin(playlistEntry, playlistEntry.playlistId.equalsExp(playlist.id))])
      ..addColumns([countExp])
      ..groupBy([playlist.id])
      ..orderBy([_order(playlist, mode)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final p = row.readTable(playlist);
        final count = row.read(countExp) ?? 0;
        return PlaylistWithCount(playlist: p, trackCount: count);
      }).toList();
    });
  }

  /// Retrieves the next available position for a new track in the specified playlist by finding the maximum existing
  /// position and adding one to it. If there are no tracks, it returns 0.
  Future<int> getNextPosition(int playlistId) async {
    final maxPos = playlistEntry.position.max();
    final query = selectOnly(playlistEntry)
      ..addColumns([maxPos])
      ..where(playlistEntry.playlistId.equals(playlistId));

    final row = await query.getSingleOrNull();
    final value = row?.read(maxPos);
    return value == null ? 0 : value + 1;
  }

  /// Checks if a specific track is already present in a given playlist by querying for an entry that matches both the playlist ID and track ID.
  Future<bool> containsTrack(int playlistId, int trackId) async {
    final row =
        await (select(playlistEntry)
              ..where((pe) => pe.playlistId.equals(playlistId) & pe.trackId.equals(trackId))
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  /// Inserts a new playlist entry into the database and returns its ID.
  Future<int> insertPlaylistEntry(PlaylistEntryCompanion entry) {
    return into(playlistEntry).insert(entry);
  }

  /// Inserts multiple playlist entries into the database in a single batch operation.
  Future<void> insertPlaylistEntries(List<PlaylistEntryCompanion> entries) async {
    if (entries.isEmpty) return;

    await batch((batch) {
      for (final entry in entries) {
        batch.insert(playlistEntry, entry);
      }
    });
  }

  /// Shifts the positions of all entries in a playlist up by one starting from a specified position.
  Future<int> shiftPositionsUpFrom(int playlistId, int position) {
    return (update(playlistEntry)
          ..where((pe) => pe.playlistId.equals(playlistId) & pe.position.isBiggerOrEqualValue(position)))
        .write(PlaylistEntryCompanion.custom(position: playlistEntry.position + const Constant(1)));
  }

  /// Shifts the positions of all entries in a playlist down by one starting from a specified position.
  Future<int> shiftPositionsDownAfter(int playlistId, int position) {
    return (update(playlistEntry)
          ..where((pe) => pe.playlistId.equals(playlistId) & pe.position.isBiggerThanValue(position)))
        .write(PlaylistEntryCompanion.custom(position: playlistEntry.position - const Constant(1)));
  }

  /// Shifts the positions of all entries in a playlist up by one within a specified range of positions.
  Future<int> shiftPositionsDownInRange(int playlistId, int from, int to) {
    return (update(playlistEntry)
          ..where((pe) => pe.playlistId.equals(playlistId) & pe.position.isBetweenValues(from, to)))
        .write(PlaylistEntryCompanion.custom(position: playlistEntry.position - const Constant(1)));
  }

  /// Shifts the positions of all entries in a playlist down by one within a specified range of positions.
  Future<int> shiftPositionsUpInRange(int playlistId, int from, int to) {
    return (update(playlistEntry)
          ..where((pe) => pe.playlistId.equals(playlistId) & pe.position.isBetweenValues(from, to)))
        .write(PlaylistEntryCompanion.custom(position: playlistEntry.position + const Constant(1)));
  }

  /// Retrieves all entries for a specific playlist, ordered by their position.
  Future<List<PlaylistEntryData>> getEntriesForPlaylist(int playlistId) {
    return (select(playlistEntry)
          ..where((pe) => pe.playlistId.equals(playlistId))
          ..orderBy([(pe) => OrderingTerm(expression: pe.position)]))
        .get();
  }

  /// Watches all entries for a specific playlist, ordered by their position, and emits updates whenever the data changes.
  Stream<List<PlaylistEntryData>> watchEntriesForPlaylist(int playlistId) {
    return (select(playlistEntry)
          ..where((pe) => pe.playlistId.equals(playlistId))
          ..orderBy([(pe) => OrderingTerm(expression: pe.position)]))
        .watch();
  }

  /// Retrieves a single playlist entry by its ID, or null if it doesn't exist.
  Future<PlaylistEntryData?> getEntryById(int entryId) {
    return (select(playlistEntry)..where((pe) => pe.id.equals(entryId))).getSingleOrNull();
  }

  /// Retrieves all entries for a specific playlist that match a given track ID, ordered by their position.
  Future<List<PlaylistEntryData>> getEntriesByTrackId(int playlistId, int trackId) {
    return (select(playlistEntry)
          ..where((pe) => pe.playlistId.equals(playlistId) & pe.trackId.equals(trackId))
          ..orderBy([(pe) => OrderingTerm(expression: pe.position)]))
        .get();
  }

  /// Updates a playlist entry by its ID with the provided entry data and returns the number of rows affected.
  Future<int> updateEntryById(int entryId, PlaylistEntryCompanion entry) {
    return (update(playlistEntry)..where((pe) => pe.id.equals(entryId))).write(entry);
  }

  /// Deletes a playlist entry by its ID and returns the number of rows affected.
  Future<int> deleteEntryById(int entryId) {
    return (delete(playlistEntry)..where((pe) => pe.id.equals(entryId))).go();
  }

  /// Deletes all playlist entries that match a given track ID within a specific playlist and returns the number of rows affected.
  Future<int> deleteEntriesByTrackId(int playlistId, int trackId) {
    return (delete(playlistEntry)..where((pe) => pe.playlistId.equals(playlistId) & pe.trackId.equals(trackId))).go();
  }

  /// Deletes all entries for a specific playlist and returns the number of rows affected.
  Future<int> deleteEntriesForPlaylist(int playlistId) {
    return (delete(playlistEntry)..where((pe) => pe.playlistId.equals(playlistId))).go();
  }

  /// Retrieves all playlist entries for a specific playlist along with their associated track data, ordered by their position.
  Future<List<PlaylistEntryWithTrack>> getPlaylistTracks(int playlistId) async {
    final query = select(playlistEntry).join([innerJoin(track, track.id.equalsExp(playlistEntry.trackId))])
      ..where(playlistEntry.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistEntry.position)]);

    final rows = await query.get();

    return rows
        .map((row) => PlaylistEntryWithTrack(entry: row.readTable(playlistEntry), track: row.readTable(track)))
        .toList();
  }

  /// Watches all playlist entries for a specific playlist along with their associated track data, ordered by their position,
  Stream<List<PlaylistEntryWithTrack>> watchPlaylistTracks(int playlistId) {
    final query = select(playlistEntry).join([innerJoin(track, track.id.equalsExp(playlistEntry.trackId))])
      ..where(playlistEntry.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistEntry.position)]);

    return query.watch().map((rows) {
      return rows
          .map((row) => PlaylistEntryWithTrack(entry: row.readTable(playlistEntry), track: row.readTable(track)))
          .toList();
    });
  }
}
