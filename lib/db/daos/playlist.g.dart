// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// ignore_for_file: type=lint
mixin _$PlaylistDaoMixin on DatabaseAccessor<Db> {
  $PlaylistTable get playlist => attachedDatabase.playlist;
  $TrackTable get track => attachedDatabase.track;
  $PlaylistEntryTable get playlistEntry => attachedDatabase.playlistEntry;
  PlaylistDaoManager get managers => PlaylistDaoManager(this);
}

class PlaylistDaoManager {
  final _$PlaylistDaoMixin _db;
  PlaylistDaoManager(this._db);
  $$PlaylistTableTableManager get playlist =>
      $$PlaylistTableTableManager(_db.attachedDatabase, _db.playlist);
  $$TrackTableTableManager get track =>
      $$TrackTableTableManager(_db.attachedDatabase, _db.track);
  $$PlaylistEntryTableTableManager get playlistEntry =>
      $$PlaylistEntryTableTableManager(_db.attachedDatabase, _db.playlistEntry);
}
