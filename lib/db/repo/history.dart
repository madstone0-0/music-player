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

  Stream<List<HistoryWithTrack>> watchRecentWithTracks({int limit = 10}) =>
      _db.historyDao.watchRecentHistoryWithTracks(limit: limit);

  Stream<List<TrackPlayStat>> watchMostPlayed({int limit = 5}) => _db.historyDao.watchTopPlayedTracks(limit: limit);

  Stream<List<PlaylistActivity>> watchRecentPlaylistActivity({int limit = 3}) =>
      _db.historyDao.watchRecentPlaylistActivity(limit: limit);
}
