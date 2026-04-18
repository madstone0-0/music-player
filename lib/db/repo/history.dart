import 'package:music_player/db/daos/history.dart';

import '../db.dart';

class HistoryRepository {
  HistoryRepository(this._db);

  final Db _db;

  Future<int> addEntry(int trackId, {DateTime? playedAt}) {
    return _db.historyDao.insertPlayedTrack(trackId: trackId, playedAt: playedAt);
  }

  Future<List<HistoryData>> getAll() => _db.historyDao.getFullHistory();

  Future<List<HistoryData>> getByTrack(int trackId) => _db.historyDao.getHistoryForTrack(trackId);

  Future<int> removeById(int id) => _db.historyDao.deleteEntry(id);

  Future<int> clearAll() => _db.historyDao.clearHistory();

  Future<List<HistoryWithTrack>> getAllWithTracks() => _db.historyDao.getHistoryWithTracks();

  Stream<List<HistoryWithTrack>> watchAllWithTracks() => _db.historyDao.watchHistoryWithTracks();
}
