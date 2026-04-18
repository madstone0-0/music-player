import 'package:drift/drift.dart';
import 'package:music_player/db/tables/track.dart';

class History extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get trackId => integer().references(Track, #id)();

  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();
}
