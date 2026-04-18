// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// ignore_for_file: type=lint
mixin _$HistoryDaoMixin on DatabaseAccessor<Db> {
  $TrackTable get track => attachedDatabase.track;
  $HistoryTable get history => attachedDatabase.history;
  HistoryDaoManager get managers => HistoryDaoManager(this);
}

class HistoryDaoManager {
  final _$HistoryDaoMixin _db;
  HistoryDaoManager(this._db);
  $$TrackTableTableManager get track =>
      $$TrackTableTableManager(_db.attachedDatabase, _db.track);
  $$HistoryTableTableManager get history =>
      $$HistoryTableTableManager(_db.attachedDatabase, _db.history);
}
