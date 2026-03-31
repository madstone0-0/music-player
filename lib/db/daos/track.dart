import 'package:drift/drift.dart';
import 'package:music_player/db/db.dart';

import '../tables/track.dart';

part "track.g.dart";

enum SortMode {
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

OrderingTerm _order(dynamic t, SortMode mode) {
  switch (mode) {
    case SortMode.titleAsc:
      return OrderingTerm(expression: t.title);
    case SortMode.titleDesc:
      return OrderingTerm(expression: t.title, mode: OrderingMode.desc);
    case SortMode.artistAsc:
      return OrderingTerm(expression: t.artist);
    case SortMode.artistDesc:
      return OrderingTerm(expression: t.artist, mode: OrderingMode.desc);
    case SortMode.albumAsc:
      return OrderingTerm(expression: t.album);
    case SortMode.albumDesc:
      return OrderingTerm(expression: t.album, mode: OrderingMode.desc);
    case SortMode.trackNoAsc:
      return OrderingTerm(expression: t.trackNo);
    case SortMode.trackNoDesc:
      return OrderingTerm(expression: t.trackNo, mode: OrderingMode.desc);
    case SortMode.yearAsc:
      return OrderingTerm(expression: t.year);
    case SortMode.yearDesc:
      return OrderingTerm(expression: t.year, mode: OrderingMode.desc);
    case SortMode.albumArtistAsc:
      return OrderingTerm(expression: t.albumArtist);
    case SortMode.albumArtistDesc:
      return OrderingTerm(expression: t.albumArtist, mode: OrderingMode.desc);
  }
}

@DriftAccessor(tables: [Track])
class TrackDao extends DatabaseAccessor<AppDatabase> with _$TrackDaoMixin {
  TrackDao(super.attachedDatabase);

  Future<List<TrackData>> getAllTracks() {
    return select(track).get();
  }

  Future<TrackData> getTrackById(int id) {
    return (select(track)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<List<TrackData>> getTracksByIds(List<int> ids) {
    return (select(track)..where((t) => t.id.isIn(ids))).get();
  }

  Stream<List<Map<String, dynamic>>> watchGroupedAlbums({SortMode mode = SortMode.albumAsc}) {
    final trackCount = track.id.count();

    final query = select(track).addColumns([trackCount])
      ..groupBy([track.album])
      ..orderBy([_order(track, mode)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final trackData = row.readTable(track);
        final count = row.read(trackCount);

        return {
          ...trackData.toJson(), // Converts TrackData back to a Map
          'trackCount': count,
        };
      }).toList();
    });
  }

  Stream<List<TrackData>> watchAllTracks({SortMode mode = SortMode.titleAsc}) {
    return (select(track)..orderBy([(t) => _order(t, mode)])).watch();
  }

  Stream<List<Map<String, dynamic>>> watchGroupedArtists({SortMode mode = SortMode.artistAsc}) {
    final trackCount = track.id.count();
    final query = select(track).addColumns([trackCount])
      ..groupBy([track.artist])
      ..orderBy([_order(track, mode)]);

    return query.watch().map(
      (rows) => rows.map((row) {
        final trackData = row.readTable(track);
        final count = row.read(trackCount);
        return {...trackData.toJson(), 'trackCount': count};
      }).toList(),
    );
  }

  Stream<List<Map<String, dynamic>>> watchGroupedAlbumArtists({SortMode mode = SortMode.artistAsc}) {
    final trackCount = track.id.count();
    final query = select(track).addColumns([trackCount])
      ..groupBy([track.albumArtist])
      ..orderBy([_order(track, mode)]);

    return query.watch().map(
      (rows) => rows.map((row) {
        final trackData = row.readTable(track);
        final count = row.read(trackCount);
        return {...trackData.toJson(), 'trackCount': count};
      }).toList(),
    );
  }

  Stream<List<TrackData>> watchTracksByArtist(String name) {
    return (select(track)
          ..where((t) => t.artist.equals(name))
          ..orderBy([(t) => _order(t, SortMode.albumAsc)]))
        .watch();
  }

  Stream<List<TrackData>> watchTracksByAlbumArtist(String name) {
    return (select(track)
          ..where((t) => t.albumArtist.equals(name))
          ..orderBy([(t) => _order(t, SortMode.albumAsc)]))
        .watch();
  }

  Stream<List<Map<String, dynamic>>> watchAlbumsByArtist(
    String name, {
    ArtistGrouping grouping = ArtistGrouping.artist,
  }) {
    final trackCount = track.id.count();

    final query = select(track).addColumns([trackCount])
      ..where(grouping == ArtistGrouping.artist ? track.artist.equals(name) : track.albumArtist.equals(name))
      ..groupBy([track.album])
      ..orderBy([OrderingTerm(expression: track.year, mode: OrderingMode.desc)]);

    return query.watch().map(
      (rows) => rows.map((row) {
        final trackData = row.readTable(track);
        final count = row.read(trackCount);
        return {...trackData.toJson(), 'trackCount': count};
      }).toList(),
    );
  }

  Future<TrackData?> getTrackByPath(String filePath) {
    return (select(track)..where((t) => t.path.equals(filePath))).getSingleOrNull();
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
    return into(track).insertOnConflictUpdate(entry);
  }

  Future<int> updateTrackMetadata({
    required int id,
    required String title,
    String? artist,
    String? album,
    String? genre,
    DateTime? lastModified,
  }) {
    return (update(track)..where((t) => t.id.equals(id))).write(
      TrackCompanion(
        title: Value(title),
        artist: Value(artist),
        album: Value(album),
        genre: Value(genre),
        lastModified: Value(lastModified),
      ),
    );
  }

  Future<int> deleteTrackByPath(String filePath) {
    return (delete(track)..where((t) => t.path.equals(filePath))).go();
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
}
