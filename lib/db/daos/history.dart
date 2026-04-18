import 'package:drift/drift.dart';
import 'package:music_player/db/db.dart';

import '../tables/history.dart';

part 'history.g.dart';

@DriftAccessor(tables: [History])
class HistoryDao extends DatabaseAccessor<Db> with _$HistoryDaoMixin {
  HistoryDao(super.attachedDatabase);

  Future<int> insertPlayedTrack({
    required int trackId,
    DateTime? playedAt,
  }) {
    final entry = HistoryCompanion.insert(
      trackId: trackId,
      playedAt: playedAt == null ? const Value.absent() : Value(playedAt),
    );
    return into(history).insert(entry);
  }

  Future<List<HistoryData>> getFullHistory() {
    return (select(history)
      ..orderBy([(row) => OrderingTerm(expression: row.playedAt, mode: OrderingMode.desc)]))
        .get();
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
}
