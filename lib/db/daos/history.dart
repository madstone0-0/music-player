import 'package:drift/drift.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/tables/history.dart';
import 'package:music_player/db/tables/track.dart';

part 'history.g.dart';

/// Combines a history entry with its associated track data for easier access in the UI.
class HistoryWithTrack {
  HistoryWithTrack({required this.entry, required this.track});

  final HistoryData entry;
  final TrackData track;
}

/// Represents the play count and last played date for a track, used for displaying top played tracks.
class TrackPlayStat {
  TrackPlayStat({required this.track, required this.playCount, required this.lastPlayed});

  final TrackData track;
  final int playCount;
  final DateTime? lastPlayed;
}

/// Represents a playlist along with the last time any track from it was played, used for displaying recent playlist activity.
class PlaylistActivity {
  PlaylistActivity({required this.playlist, required this.lastPlayed});

  final PlaylistData playlist;
  final DateTime lastPlayed;
}

@DriftAccessor(tables: [History])
class HistoryDao extends DatabaseAccessor<Db> with _$HistoryDaoMixin {
  HistoryDao(super.attachedDatabase);

  /// Inserts a new history entry for a played track. If [playedAt] is not provided, the database will use the current timestamp.
  Future<int> insertPlayedTrack({required int trackId, DateTime? playedAt}) {
    final entry = HistoryCompanion.insert(
      trackId: trackId,
      playedAt: playedAt == null ? const Value.absent() : Value(playedAt),
    );
    return into(history).insert(entry);
  }

  /// Retrieves the full play history, ordered by most recent plays first.
  Future<List<HistoryData>> getFullHistory() {
    return (select(history)..orderBy([(row) => OrderingTerm(expression: row.playedAt, mode: OrderingMode.desc)])).get();
  }

  /// Retrieves the play history for a specific track, ordered by most recent plays first.
  Future<List<HistoryData>> getHistoryForTrack(int trackId) {
    return (select(history)
          ..where((row) => row.trackId.equals(trackId))
          ..orderBy([(row) => OrderingTerm(expression: row.playedAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Deletes a specific history entry by its ID. Returns the number of rows affected (should be 1 if successful).
  Future<int> deleteEntry(int id) {
    return (delete(history)..where((row) => row.id.equals(id))).go();
  }

  /// Clears the entire play history. Returns the number of rows deleted.
  Future<int> clearHistory() {
    return delete(history).go();
  }

  /// Retrieves the play history along with associated track data, ordered by most recent plays first.
  Future<List<HistoryWithTrack>> getHistoryWithTracks() async {
    final query = select(history).join([innerJoin(track, track.id.equalsExp(history.trackId))])
      ..orderBy([OrderingTerm(expression: history.playedAt, mode: OrderingMode.desc)]);

    final rows = await query.get();
    return rows
        .map((row) => HistoryWithTrack(entry: row.readTable(history), track: row.readTable(track)))
        .toList(growable: false);
  }

  /// Watches the play history along with associated track data, emitting updates whenever the history or track data changes. Ordered by most recent plays first.
  Stream<List<HistoryWithTrack>> watchHistoryWithTracks() {
    final query = select(history).join([innerJoin(track, track.id.equalsExp(history.trackId))])
      ..orderBy([OrderingTerm(expression: history.playedAt, mode: OrderingMode.desc)]);

    return query.watch().map(
      (rows) => rows
          .map((row) => HistoryWithTrack(entry: row.readTable(history), track: row.readTable(track)))
          .toList(growable: false),
    );
  }

  /// Watches the most recent play history entries along with associated track data, limited to [limit] entries. Emits updates whenever the history or track data changes.
  Stream<List<HistoryWithTrack>> watchRecentHistoryWithTracks({int limit = 10}) {
    if (limit <= 0) return Stream.value(const <HistoryWithTrack>[]);

    final query = select(history).join([innerJoin(track, track.id.equalsExp(history.trackId))])
      ..orderBy([OrderingTerm(expression: history.playedAt, mode: OrderingMode.desc)])
      ..limit(limit);

    return query.watch().map(
      (rows) => rows
          .map((row) => HistoryWithTrack(entry: row.readTable(history), track: row.readTable(track)))
          .toList(growable: false),
    );
  }

  /// Watches the top played tracks based on play count and last played date, limited to [limit] entries.
  /// Emits updates whenever the history or track data changes.
  Stream<List<TrackPlayStat>> watchTopPlayedTracks({int limit = 5}) {
    if (limit <= 0) return Stream.value(const <TrackPlayStat>[]);

    final playCount = history.id.count();
    final lastPlayed = history.playedAt.max();

    final query = select(history).join([innerJoin(track, track.id.equalsExp(history.trackId))])
      ..addColumns([playCount, lastPlayed])
      ..where(track.isIndexed.equals(true))
      ..groupBy([history.trackId])
      ..orderBy([
        OrderingTerm(expression: playCount, mode: OrderingMode.desc),
        OrderingTerm(expression: lastPlayed, mode: OrderingMode.desc),
        OrderingTerm(expression: track.title),
      ])
      ..limit(limit);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => TrackPlayStat(
              track: row.readTable(track),
              playCount: row.read(playCount) ?? 0,
              lastPlayed: row.read(lastPlayed),
            ),
          )
          .toList(growable: false);
    });
  }

  /// Watches the most recently active playlists based on the last played date of any track from the playlist,
  /// limited to [limit] entries. Emits updates whenever the history, playlist entry, or playlist data changes.
  Stream<List<PlaylistActivity>> watchRecentPlaylistActivity({int limit = 3}) {
    if (limit <= 0) return Stream.value(const <PlaylistActivity>[]);

    final playlist = attachedDatabase.playlist;
    final playlistEntry = attachedDatabase.playlistEntry;
    final lastPlayed = history.playedAt.max();

    final query =
        select(history).join([
            innerJoin(playlistEntry, playlistEntry.trackId.equalsExp(history.trackId)),
            innerJoin(playlist, playlist.id.equalsExp(playlistEntry.playlistId)),
          ])
          ..addColumns([lastPlayed])
          ..groupBy([playlist.id])
          ..orderBy([
            OrderingTerm(expression: lastPlayed, mode: OrderingMode.desc),
            OrderingTerm(expression: playlist.updatedAt, mode: OrderingMode.desc),
          ])
          ..limit(limit);

    return query.watch().map((rows) {
      return rows
          .map((row) => PlaylistActivity(playlist: row.readTable(playlist), lastPlayed: row.read(lastPlayed)!))
          .toList(growable: false);
    });
  }
}
