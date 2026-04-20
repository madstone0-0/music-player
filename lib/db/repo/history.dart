import 'package:music_player/db/daos/history.dart';

import '../db.dart';

class HistoryRepository {
  HistoryRepository(this._db);

  final Db _db;

  /// Adds a new entry to the history for the given track ID and optional playedAt timestamp.
  Future<int> addEntry(int trackId, {DateTime? playedAt}) {
    return _db.historyDao.insertPlayedTrack(trackId: trackId, playedAt: playedAt);
  }

  /// Retrieves all history entries, ordered by most recent first.
  Future<List<HistoryData>> getAll() => _db.historyDao.getFullHistory();

  /// Retrieves all history entries for a specific track ID, ordered by most recent first.
  Future<List<HistoryData>> getByTrack(int trackId) => _db.historyDao.getHistoryForTrack(trackId);

  /// Removes a history entry by its unique ID. Returns the number of rows affected (should be 1 if successful).
  Future<int> removeById(int id) => _db.historyDao.deleteEntry(id);

  /// Clears all history entries from the database. Returns the number of rows affected.
  Future<int> clearAll() => _db.historyDao.clearHistory();

  /// Retrieves all history entries along with their associated track information, ordered by most recent first.
  Future<List<HistoryWithTrack>> getAllWithTracks() => _db.historyDao.getHistoryWithTracks();

  /// Retrieves the most recent history entries along with their associated track information, limited by the specified number.
  Stream<List<HistoryWithTrack>> watchAllWithTracks() => _db.historyDao.watchHistoryWithTracks();

  /// Retrieves the most recent history entries along with their associated track information, limited by the specified number.
  Stream<List<HistoryWithTrack>> watchRecentWithTracks({int limit = 10}) =>
      _db.historyDao.watchRecentHistoryWithTracks(limit: limit);

  /// Retrieves the most played tracks along with their play counts, limited by the specified number.
  Stream<List<TrackPlayStat>> watchMostPlayed({int limit = 5}) => _db.historyDao.watchTopPlayedTracks(limit: limit);

  /// Retrieves the most recent playlist activity, including playlist name and last played timestamp, limited by the specified number.
  Stream<List<PlaylistActivity>> watchRecentPlaylistActivity({int limit = 3}) =>
      _db.historyDao.watchRecentPlaylistActivity(limit: limit);
}
