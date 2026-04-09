import 'package:drift/drift.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/tables/playlist.dart';
import 'package:music_player/db/tables/track.dart';

part "playlist.g.dart";

enum PlaylistSortMode {
  nameAsc,
  nameDesc,
  createdAtAsc,
  createdAtDesc,
  updatedAtAsc,
  updatedAtDesc,
}

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

typedef PlaylistWithCount = ({PlaylistData playlist, int trackCount});
typedef PlaylistEntryWithTrack = ({PlaylistEntryData entry, TrackData track});

@DriftAccessor(tables: [Playlist, PlaylistEntry, Track])
class PlaylistDao extends DatabaseAccessor<Db> with _$PlaylistDaoMixin {
  PlaylistDao(super.attachedDatabase);

  Future<void> touchPlaylist(int playlistId) {
    return (update(playlist)..where((p) => p.id.equals(playlistId))).write(
      PlaylistCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  Future<int> insertPlaylist(PlaylistCompanion entry) {
    return into(playlist).insert(entry);
  }

  Future<int> updatePlaylistById(int id, PlaylistCompanion entry) {
    return (update(playlist)..where((p) => p.id.equals(id))).write(entry);
  }

  Future<int> deletePlaylistById(int id) {
    return (delete(playlist)..where((p) => p.id.equals(id))).go();
  }

  Future<List<PlaylistData>> getAllPlaylists({
    PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc,
  }) {
    return (select(playlist)..orderBy([(p) => _order(p, mode)])).get();
  }

  Stream<List<PlaylistData>> watchAllPlaylists({
    PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc,
  }) {
    return (select(playlist)..orderBy([(p) => _order(p, mode)])).watch();
  }

  Future<PlaylistData?> getPlaylistById(int id) {
    return (select(playlist)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<PlaylistData?> getPlaylistByName(String name) {
    return (select(playlist)..where((p) => p.name.equals(name))).getSingleOrNull();
  }

  Future<List<PlaylistWithCount>> getPlaylistsWithTrackCounts({
    PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc,
  }) async {
    final countExp = playlistEntry.id.count();
    final query = select(playlist).join([
      leftOuterJoin(playlistEntry, playlistEntry.playlistId.equalsExp(playlist.id)),
    ])
      ..addColumns([countExp])
      ..groupBy([playlist.id])
      ..orderBy([_order(playlist, mode)]);

    final rows = await query.get();

    return rows.map((row) {
      final p = row.readTable(playlist);
      final count = row.read(countExp) ?? 0;
      return (playlist: p, trackCount: count);
    }).toList();
  }

  Stream<List<PlaylistWithCount>> watchPlaylistsWithTrackCounts({
    PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc,
  }) {
    final countExp = playlistEntry.id.count();
    final query = select(playlist).join([
      leftOuterJoin(playlistEntry, playlistEntry.playlistId.equalsExp(playlist.id)),
    ])
      ..addColumns([countExp])
      ..groupBy([playlist.id])
      ..orderBy([_order(playlist, mode)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final p = row.readTable(playlist);
        final count = row.read(countExp) ?? 0;
        return (playlist: p, trackCount: count);
      }).toList();
    });
  }

  Future<int> getNextPosition(int playlistId) async {
    final maxPos = playlistEntry.position.max();
    final query = selectOnly(playlistEntry)
      ..addColumns([maxPos])
      ..where(playlistEntry.playlistId.equals(playlistId));

    final row = await query.getSingleOrNull();
    final value = row?.read(maxPos);
    return value == null ? 0 : value + 1;
  }

  Future<bool> containsTrack(int playlistId, int trackId) async {
    final row = await (select(playlistEntry)
      ..where((pe) => pe.playlistId.equals(playlistId) & pe.trackId.equals(trackId))
      ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<int> insertPlaylistEntry(PlaylistEntryCompanion entry) {
    return into(playlistEntry).insert(entry);
  }

  Future<void> insertPlaylistEntries(List<PlaylistEntryCompanion> entries) async {
    if (entries.isEmpty) return;

    await batch((batch) {
      for (final entry in entries) {
        batch.insert(playlistEntry, entry);
      }
    });
  }

  Future<int> shiftPositionsUpFrom(int playlistId, int position) {
    return (update(playlistEntry)
      ..where((pe) =>
      pe.playlistId.equals(playlistId) &
      pe.position.isBiggerOrEqualValue(position)))
        .write(
      PlaylistEntryCompanion.custom(
        position: playlistEntry.position + const Constant(1),
      ),
    );
  }

  Future<int> shiftPositionsDownAfter(int playlistId, int position) {
    return (update(playlistEntry)
      ..where((pe) =>
      pe.playlistId.equals(playlistId) &
      pe.position.isBiggerThanValue(position)))
        .write(
      PlaylistEntryCompanion.custom(
        position: playlistEntry.position - const Constant(1),
      ),
    );
  }

  Future<int> shiftPositionsDownInRange(int playlistId, int from, int to) {
    return (update(playlistEntry)
      ..where((pe) =>
      pe.playlistId.equals(playlistId) &
      pe.position.isBetweenValues(from, to)))
        .write(
      PlaylistEntryCompanion.custom(
        position: playlistEntry.position - const Constant(1),
      ),
    );
  }

  Future<int> shiftPositionsUpInRange(int playlistId, int from, int to) {
    return (update(playlistEntry)
      ..where((pe) =>
      pe.playlistId.equals(playlistId) &
      pe.position.isBetweenValues(from, to)))
        .write(
      PlaylistEntryCompanion.custom(
        position: playlistEntry.position + const Constant(1),
      ),
    );
  }

  Future<List<PlaylistEntryData>> getEntriesForPlaylist(int playlistId) {
    return (select(playlistEntry)
      ..where((pe) => pe.playlistId.equals(playlistId))
      ..orderBy([(pe) => OrderingTerm(expression: pe.position)]))
        .get();
  }

  Stream<List<PlaylistEntryData>> watchEntriesForPlaylist(int playlistId) {
    return (select(playlistEntry)
      ..where((pe) => pe.playlistId.equals(playlistId))
      ..orderBy([(pe) => OrderingTerm(expression: pe.position)]))
        .watch();
  }

  Future<PlaylistEntryData?> getEntryById(int entryId) {
    return (select(playlistEntry)..where((pe) => pe.id.equals(entryId))).getSingleOrNull();
  }

  Future<List<PlaylistEntryData>> getEntriesByTrackId(int playlistId, int trackId) {
    return (select(playlistEntry)
      ..where((pe) => pe.playlistId.equals(playlistId) & pe.trackId.equals(trackId))
      ..orderBy([(pe) => OrderingTerm(expression: pe.position)]))
        .get();
  }

  Future<int> updateEntryById(int entryId, PlaylistEntryCompanion entry) {
    return (update(playlistEntry)..where((pe) => pe.id.equals(entryId))).write(entry);
  }

  Future<int> deleteEntryById(int entryId) {
    return (delete(playlistEntry)..where((pe) => pe.id.equals(entryId))).go();
  }

  Future<int> deleteEntriesByTrackId(int playlistId, int trackId) {
    return (delete(playlistEntry)
      ..where((pe) => pe.playlistId.equals(playlistId) & pe.trackId.equals(trackId)))
        .go();
  }

  Future<int> deleteEntriesForPlaylist(int playlistId) {
    return (delete(playlistEntry)..where((pe) => pe.playlistId.equals(playlistId))).go();
  }

  Future<List<PlaylistEntryWithTrack>> getPlaylistTracks(int playlistId) async {
    final query = select(playlistEntry).join([
      innerJoin(track, track.id.equalsExp(playlistEntry.trackId)),
    ])
      ..where(playlistEntry.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistEntry.position)]);

    final rows = await query.get();

    return rows
        .map((row) => (
    entry: row.readTable(playlistEntry),
    track: row.readTable(track),
    ))
        .toList();
  }

  Stream<List<PlaylistEntryWithTrack>> watchPlaylistTracks(int playlistId) {
    final query = select(playlistEntry).join([
      innerJoin(track, track.id.equalsExp(playlistEntry.trackId)),
    ])
      ..where(playlistEntry.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistEntry.position)]);

    return query.watch().map((rows) {
      return rows
          .map((row) => (
      entry: row.readTable(playlistEntry),
      track: row.readTable(track),
      ))
          .toList();
    });
  }
}
