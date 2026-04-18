import 'package:drift/drift.dart';

class History extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get trackId => integer()();

  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();
}
