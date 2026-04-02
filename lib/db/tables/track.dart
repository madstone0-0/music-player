import 'package:drift/drift.dart';

@TableIndex(name: "title_artist", columns: {#title, #artist})
@TableIndex(name: "path", columns: {#path})
@TableIndex(name: "artist_album", columns: {#artist, #album})
@TableIndex(name: "album_artist_album", columns: {#albumArtist, #album})
@TableIndex(name: "artist", columns: {#artist})
@TableIndex(name: "album", columns: {#album})
@TableIndex(name: "albumArtist", columns: {#albumArtist})
class Track extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get trackNo => integer().nullable()();

  TextColumn get path => text().unique()();

  TextColumn get title => text().customConstraint("NOT NULL COLLATE NOCASE")();

  TextColumn get artist => text().nullable().customConstraint("COLLATE NOCASE")();

  TextColumn get albumArtist => text().nullable().customConstraint("COLLATE NOCASE")();

  TextColumn get album => text().nullable().customConstraint("COLLATE NOCASE")();

  TextColumn get genre => text().nullable().customConstraint("COLLATE NOCASE")();

  IntColumn get year => integer().nullable()();

  TextColumn get coverPath => text().nullable()();

  DateTimeColumn get lastModified => dateTime().nullable()();

  BoolColumn get isIndexed => boolean().withDefault(const Constant(true))();
}
