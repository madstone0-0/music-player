import 'package:drift/drift.dart';

@TableIndex(name: "title_artist", columns: {#title, #artist})
class Track extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get path => text().unique()();

  TextColumn get title => text()();

  TextColumn get artist => text().nullable()();

  TextColumn get album => text().nullable()();

  TextColumn get genre => text().nullable()();

  TextColumn get coverPath => text().nullable()();

  DateTimeColumn get lastModified => dateTime().nullable()();

  BoolColumn get isIndexed => boolean().withDefault(const Constant(true))();
}
