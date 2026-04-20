import 'dart:async';

import 'package:get/get.dart';
import 'package:music_player/db/daos/history.dart';
import 'package:music_player/db/daos/playlist.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/history.dart';
import 'package:music_player/db/repo/playlist.dart';
import 'package:music_player/services/LocatorService.dart';

/// Combines a playlist with its last played time and track count for display on the home screen.
class HomePlaylistItem {
  HomePlaylistItem({required this.playlist, required this.lastPlayed, required this.trackCount});

  final PlaylistData playlist;
  final DateTime lastPlayed;
  final int trackCount;
}

class HomeViewModel extends GetxController {
  final HistoryRepository _historyRepo = getIt<HistoryRepository>();
  final PlaylistRepository _playlistRepo = getIt<PlaylistRepository>();

  final mostPlayedTracks = <TrackPlayStat>[].obs;
  final recentPlaylists = <HomePlaylistItem>[].obs;
  final recentTracks = <HistoryWithTrack>[].obs;

  final int mostPlayedLimit = 5;
  final int recentPlaylistLimit = 3;
  final int recentTracksLimit = 10;

  StreamSubscription<List<TrackPlayStat>>? _mostPlayedSub;
  StreamSubscription<List<PlaylistActivity>>? _playlistActivitySub;
  StreamSubscription<List<HistoryWithTrack>>? _recentTracksSub;
  StreamSubscription<List<PlaylistWithCount>>? _playlistCountsSub;

  List<PlaylistActivity> _playlistActivity = [];
  Map<int, int> _playlistCounts = {};

  bool get hasContent => mostPlayedTracks.isNotEmpty || recentPlaylists.isNotEmpty || recentTracks.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _fetch();
  }

  void _fetch() {
    _bindMostPlayed();
    _bindRecentTracks();
    _bindPlaylistActivity();
    _bindPlaylistCounts();
  }

  void _bindMostPlayed() {
    _mostPlayedSub?.cancel();
    _mostPlayedSub = _historyRepo.watchMostPlayed(limit: mostPlayedLimit).listen((items) {
      if (isClosed) return;
      mostPlayedTracks.assignAll(items);
    });
  }

  void _bindRecentTracks() {
    _recentTracksSub?.cancel();
    _recentTracksSub = _historyRepo.watchRecentWithTracks(limit: recentTracksLimit).listen((items) {
      if (isClosed) return;
      recentTracks.assignAll(items);
    });
  }

  void _bindPlaylistActivity() {
    _playlistActivitySub?.cancel();
    _playlistActivitySub = _historyRepo.watchRecentPlaylistActivity(limit: recentPlaylistLimit).listen((items) {
      if (isClosed) return;
      _playlistActivity = List.of(items);
      _rebuildPlaylistItems();
    });
  }

  void _bindPlaylistCounts() {
    _playlistCountsSub?.cancel();
    _playlistCountsSub = _playlistRepo.watchPlaylistsWithTrackCounts().listen((items) {
      if (isClosed) return;
      _playlistCounts = {for (final item in items) item.playlist.id: item.trackCount};
      _rebuildPlaylistItems();
    });
  }

  /// Rebuilds the list of recent playlist items by combining the recent playlist activity with the track counts.
  void _rebuildPlaylistItems() {
    if (isClosed) return;
    if (_playlistActivity.isEmpty) {
      recentPlaylists.clear();
      return;
    }

    final counts = _playlistCounts;
    final mapped = _playlistActivity
        .map(
          (activity) => HomePlaylistItem(
            playlist: activity.playlist,
            lastPlayed: activity.lastPlayed,
            trackCount: counts[activity.playlist.id] ?? 0,
          ),
        )
        .toList(growable: false);

    recentPlaylists.assignAll(mapped);
  }

  @override
  void onClose() {
    _mostPlayedSub?.cancel();
    _playlistActivitySub?.cancel();
    _recentTracksSub?.cancel();
    _playlistCountsSub?.cancel();
    super.onClose();
  }
}
