import 'package:drift/drift.dart';
import 'package:music_player/db/tables/track.dart';

class Playlist extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().customConstraint("NOT NULL COLLATE NOCASE UNIQUE")();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get lastPlayed => dateTime().nullable()();
}

class PlaylistEntry extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get playlistId => integer().references(Playlist, #id, onDelete: KeyAction.cascade)();

  IntColumn get trackId => integer().references(Track, #id)();

  IntColumn get position => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {playlistId, position},
  ];
}
