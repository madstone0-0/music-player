// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// ignore_for_file: type=lint
mixin _$TrackDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrackTable get track => attachedDatabase.track;
  TrackDaoManager get managers => TrackDaoManager(this);
}

class TrackDaoManager {
  final _$TrackDaoMixin _db;
  TrackDaoManager(this._db);
  $$TrackTableTableManager get track =>
      $$TrackTableTableManager(_db.attachedDatabase, _db.track);
}
