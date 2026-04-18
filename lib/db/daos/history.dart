import 'package:drift/drift.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/tables/history.dart';
import 'package:music_player/db/tables/track.dart';

part 'history.g.dart';

class HistoryWithTrack {
  HistoryWithTrack({required this.entry, required this.track});

  final HistoryData entry;
  final TrackData track;
}

@DriftAccessor(tables: [History])
class HistoryDao extends DatabaseAccessor<Db> with _$HistoryDaoMixin {
  HistoryDao(super.attachedDatabase);

  Future<int> insertPlayedTrack({required int trackId, DateTime? playedAt}) {
    final entry = HistoryCompanion.insert(
      trackId: trackId,
      playedAt: playedAt == null ? const Value.absent() : Value(playedAt),
    );
    return into(history).insert(entry);
  }

  Future<List<HistoryData>> getFullHistory() {
    return (select(history)..orderBy([(row) => OrderingTerm(expression: row.playedAt, mode: OrderingMode.desc)])).get();
  }

  Future<List<HistoryData>> getHistoryForTrack(int trackId) {
    return (select(history)
          ..where((row) => row.trackId.equals(trackId))
          ..orderBy([(row) => OrderingTerm(expression: row.playedAt, mode: OrderingMode.desc)]))
        .get();
  }

  Future<int> deleteEntry(int id) {
    return (delete(history)..where((row) => row.id.equals(id))).go();
  }

  Future<int> clearHistory() {
    return delete(history).go();
  }

  Future<List<HistoryWithTrack>> getHistoryWithTracks() async {
    final query = select(history).join([innerJoin(track, track.id.equalsExp(history.trackId))])
      ..orderBy([OrderingTerm(expression: history.playedAt, mode: OrderingMode.desc)]);

    final rows = await query.get();
    return rows
        .map((row) => HistoryWithTrack(entry: row.readTable(history), track: row.readTable(track)))
        .toList(growable: false);
  }

  Stream<List<HistoryWithTrack>> watchHistoryWithTracks() {
    final query = select(history).join([innerJoin(track, track.id.equalsExp(history.trackId))])
      ..orderBy([OrderingTerm(expression: history.playedAt, mode: OrderingMode.desc)]);

    return query.watch().map(
      (rows) => rows
          .map((row) => HistoryWithTrack(entry: row.readTable(history), track: row.readTable(track)))
          .toList(growable: false),
    );
  }
}
