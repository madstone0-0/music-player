// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// ignore_for_file: type=lint
mixin _$HistoryDaoMixin on DatabaseAccessor<Db> {
  $HistoryTable get history => attachedDatabase.history;
  HistoryDaoManager get managers => HistoryDaoManager(this);
}

class HistoryDaoManager {
  final _$HistoryDaoMixin _db;
  HistoryDaoManager(this._db);
  $$HistoryTableTableManager get history =>
      $$HistoryTableTableManager(_db.attachedDatabase, _db.history);
}
