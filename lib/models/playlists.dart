import 'dart:async';

import 'package:get/get.dart';
import 'package:music_player/db/daos/playlist.dart';
import 'package:music_player/db/repo/playlist.dart';
import 'package:music_player/services/LocatorService.dart';

class PlaylistViewModel extends GetxController {
  final _repo = getIt<PlaylistRepository>();

  final playlists = <PlaylistWithCount>[].obs;
  final sortMode = PlaylistSortMode.nameAsc.obs;
  final isLoading = true.obs;

  StreamSubscription<List<PlaylistWithCount>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _fetch();
  }

  /// Fetch playlists with track counts based on the current sort mode.
  void _fetch() {
    _sub?.cancel();
    isLoading.value = true;

    _sub = _repo.watchPlaylistsWithTrackCounts(mode: sortMode.value).listen((items) {
      playlists.assignAll(items);
      isLoading.value = false;
    });
  }

  /// Toggle sorting based on the provided label and refresh the playlist list.
  void toggleSort(String label) {
    if (label == "Name") {
      sortMode.value = (sortMode.value == PlaylistSortMode.nameAsc)
          ? PlaylistSortMode.nameDesc
          : PlaylistSortMode.nameAsc;
    } else if (label == "Created") {
      sortMode.value = (sortMode.value == PlaylistSortMode.createdAtAsc)
          ? PlaylistSortMode.createdAtDesc
          : PlaylistSortMode.createdAtAsc;
    } else if (label == 'Updated') {
      sortMode.value = (sortMode.value == PlaylistSortMode.updatedAtAsc)
          ? PlaylistSortMode.updatedAtDesc
          : PlaylistSortMode.updatedAtAsc;
    }
    _fetch();
  }

  /// Create a new playlist with the given name if it's not empty.
  Future<void> createPlaylist(String name) async {
    if (name.trim().isEmpty) return;
    await _repo.createPlaylist(name.trim());
  }

  /// Rename an existing playlist by its ID if the new name is not empty.
  Future<void> renamePlaylist(int id, String newName) async {
    if (newName.trim().isEmpty) return;
    await _repo.renamePlaylist(id, newName.trim());
  }

  /// Delete a playlist by its ID.
  Future<void> deletePlaylist(int id) async {
    await _repo.deletePlaylist(id);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
