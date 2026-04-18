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

class TrackPlayStat {
  TrackPlayStat({required this.track, required this.playCount, required this.lastPlayed});

  final TrackData track;
  final int playCount;
  final DateTime? lastPlayed;
}

class PlaylistActivity {
  PlaylistActivity({required this.playlist, required this.lastPlayed});

  final PlaylistData playlist;
  final DateTime lastPlayed;
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
