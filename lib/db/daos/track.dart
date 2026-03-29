import 'package:drift/drift.dart';
import 'package:music_player/db/db.dart';

import '../tables/track.dart';

part "track.g.dart";

enum SortMode { titleAsc, titleDesc, artistAsc, artistDesc, albumAsc, albumDesc, trackNoAsc, trackNoDesc }

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

  Stream<List<TrackData>> watchAllTracks({SortMode mode = SortMode.titleAsc}) {
    return (select(track)..orderBy([
          (t) {
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
            }
          },
        ]))
        .watch();
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
