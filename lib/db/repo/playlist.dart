import 'package:drift/drift.dart';
import 'package:music_player/db/daos/playlist.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/services/LocatorService.dart';

class PlaylistRepository {
  PlaylistRepository(this._db);

  final Db _db;

  Future<int> createPlaylist(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Playlist name cannot be empty.');
    }

    final existing = await _db.playlistDao.getPlaylistByName(trimmed);
    if (existing != null) {
      throw StateError('A playlist with that name already exists.');
    }

    return _db.playlistDao.insertPlaylist(
      PlaylistCompanion(name: Value(trimmed)),
    );
  }

  Future<void> renamePlaylist(int id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Playlist name cannot be empty.');
    }

    final existing = await _db.playlistDao.getPlaylistByName(trimmed);
    if (existing != null && existing.id != id) {
      throw StateError('A playlist with that name already exists.');
    }

    await _db.playlistDao.updatePlaylistById(
      id,
      PlaylistCompanion(
        name: Value(trimmed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deletePlaylist(int id) async {
    await _db.playlistDao.deletePlaylistById(id);
  }

  Future<List<PlaylistData>> getAllPlaylists({
    PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc,
  }) {
    return _db.playlistDao.getAllPlaylists(mode: mode);
  }

  Stream<List<PlaylistData>> watchAllPlaylists({
    PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc,
  }) {
    return _db.playlistDao.watchAllPlaylists(mode: mode);
  }

  Future<PlaylistData?> getPlaylistById(int id) {
    return _db.playlistDao.getPlaylistById(id);
  }

  Future<List<PlaylistWithCount>> getPlaylistsWithTrackCounts({
    PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc,
  }) {
    return _db.playlistDao.getPlaylistsWithTrackCounts(mode: mode);
  }

  Stream<List<PlaylistWithCount>> watchPlaylistsWithTrackCounts({
    PlaylistSortMode mode = PlaylistSortMode.updatedAtDesc,
  }) {
    return _db.playlistDao.watchPlaylistsWithTrackCounts(mode: mode);
  }

  Future<int> addTrackToPlaylist(
      int playlistId,
      int trackId, {
        int? position,
      }) async {
    return _db.playlistDao.transaction(() async {
      final insertPosition = position ?? await _db.playlistDao.getNextPosition(playlistId);

      if (position != null) {
        await _db.playlistDao.shiftPositionsUpFrom(playlistId, insertPosition);
      }

      final id = await _db.playlistDao.insertPlaylistEntry(
        PlaylistEntryCompanion(
          playlistId: Value(playlistId),
          trackId: Value(trackId),
          position: Value(insertPosition),
        ),
      );

      await _db.playlistDao.touchPlaylist(playlistId);
      return id;
    });
  }

  Future<void> addTracksToPlaylist(int playlistId, List<int> trackIds) async {
    if (trackIds.isEmpty) return;

    await _db.playlistDao.transaction(() async {
      var nextPosition = await _db.playlistDao.getNextPosition(playlistId);

      final entries = trackIds
          .map(
            (trackId) => PlaylistEntryCompanion(
          playlistId: Value(playlistId),
          trackId: Value(trackId),
          position: Value(nextPosition++),
        ),
      )
          .toList();

      await _db.playlistDao.insertPlaylistEntries(entries);
      await _db.playlistDao.touchPlaylist(playlistId);
    });
  }

  Future<void> removeEntry(int entryId) async {
    await _db.playlistDao.transaction(() async {
      final entry = await _db.playlistDao.getEntryById(entryId);
      if (entry == null) return;

      await _db.playlistDao.deleteEntryById(entryId);
      await _db.playlistDao.shiftPositionsDownAfter(entry.playlistId, entry.position);
      await _db.playlistDao.touchPlaylist(entry.playlistId);
    });
  }

  Future<void> removeTrackFromPlaylist(
      int playlistId,
      int trackId, {
        bool removeAllOccurrences = false,
      }) async {
    await _db.playlistDao.transaction(() async {
      final entries = await _db.playlistDao.getEntriesByTrackId(playlistId, trackId);
      if (entries.isEmpty) return;

      if (removeAllOccurrences) {
        final removedPositions = entries.map((e) => e.position).toList()..sort();

        await _db.playlistDao.deleteEntriesByTrackId(playlistId, trackId);

        for (var i = 0; i < removedPositions.length; i++) {
          final removedPos = removedPositions[i];
          await _db.playlistDao.shiftPositionsDownAfter(playlistId, removedPos - i);
        }
      } else {
        final entry = entries.first;
        await _db.playlistDao.deleteEntryById(entry.id);
        await _db.playlistDao.shiftPositionsDownAfter(playlistId, entry.position);
      }

      await _db.playlistDao.touchPlaylist(playlistId);
    });
  }

  Future<void> moveEntry(
      int playlistId,
      int fromPosition,
      int toPosition,
      ) async {
    if (fromPosition == toPosition) return;

    await _db.playlistDao.transaction(() async {
      final entries = await _db.playlistDao.getEntriesForPlaylist(playlistId);
      if (entries.isEmpty) return;
      if (fromPosition < 0 || fromPosition >= entries.length) return;
      if (toPosition < 0 || toPosition >= entries.length) return;

      final moving = entries.firstWhere((e) => e.position == fromPosition);

      if (fromPosition < toPosition) {
        await _db.playlistDao.shiftPositionsDownInRange(
          playlistId,
          fromPosition + 1,
          toPosition,
        );
      } else {
        await _db.playlistDao.shiftPositionsUpInRange(
          playlistId,
          toPosition,
          fromPosition - 1,
        );
      }

      await _db.playlistDao.updateEntryById(
        moving.id,
        PlaylistEntryCompanion(position: Value(toPosition)),
      );

      await _db.playlistDao.touchPlaylist(playlistId);
    });
  }

  Future<void> clearPlaylist(int playlistId) async {
    await _db.playlistDao.transaction(() async {
      await _db.playlistDao.deleteEntriesForPlaylist(playlistId);
      await _db.playlistDao.touchPlaylist(playlistId);
    });
  }

  Future<void> replacePlaylistContents(
      int playlistId,
      List<int> trackIds,
      ) async {
    await _db.playlistDao.transaction(() async {
      await _db.playlistDao.deleteEntriesForPlaylist(playlistId);

      if (trackIds.isNotEmpty) {
        final entries = <PlaylistEntryCompanion>[];
        for (int i = 0; i < trackIds.length; i++) {
          entries.add(
            PlaylistEntryCompanion(
              playlistId: Value(playlistId),
              trackId: Value(trackIds[i]),
              position: Value(i),
            ),
          );
        }
        await _db.playlistDao.insertPlaylistEntries(entries);
      }

      await _db.playlistDao.touchPlaylist(playlistId);
    });
  }

  Future<List<PlaylistEntryData>> getEntriesForPlaylist(int playlistId) {
    return _db.playlistDao.getEntriesForPlaylist(playlistId);
  }

  Stream<List<PlaylistEntryData>> watchEntriesForPlaylist(int playlistId) {
    return _db.playlistDao.watchEntriesForPlaylist(playlistId);
  }

  Future<List<PlaylistEntryWithTrack>> getPlaylistTracks(int playlistId) {
    return _db.playlistDao.getPlaylistTracks(playlistId);
  }

  Stream<List<PlaylistEntryWithTrack>> watchPlaylistTracks(int playlistId) {
    return _db.playlistDao.watchPlaylistTracks(playlistId);
  }

  Future<bool> containsTrack(int playlistId, int trackId) {
    return _db.playlistDao.containsTrack(playlistId, trackId);
  }
}
