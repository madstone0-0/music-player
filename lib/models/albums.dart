import 'package:azlistview/azlistview.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/LocatorService.dart';

class AZAlbumItem extends ISuspensionBean {
  final TrackData albumData; // Using a TrackData sample to represent the album
  final String tag;
  final int trackCount;

  AZAlbumItem({required this.albumData, required this.tag, this.trackCount = 1});

  @override
  String getSuspensionTag() => tag;
}

class AlbumsViewModel extends GetxController {
  final repo = getIt<TrackRepository>();

  final allTracks = <TrackData>[].obs;
  final azItms = <AZAlbumItem>[].obs;
  final sortMode = SortMode.albumAsc.obs; // Default to Album sort

  @override
  void onInit() {
    super.onInit();

    // Watch for tracks and regroup them into albums whenever they change
    ever(allTracks, (_) => _generateAlbumAZItems());

    // Watch sort mode to re-fetch
    ever(sortMode, (SortMode mode) => _fetchData());

    _fetchData();
  }

  void _fetchData() {
    allTracks.bindStream(repo.watchAll(mode: sortMode.value));
  }

  void _generateAlbumAZItems() {
    if (allTracks.isEmpty) {
      azItms.value = [];
      return;
    }

    // Grouping tracks by Album Name to get unique Albums
    final Map<String, List<TrackData>> grouped = {};
    for (var track in allTracks) {
      final key = track.album ?? "Unknown Album";
      grouped.putIfAbsent(key, () => []).add(track);
    }

    final List<AZAlbumItem> mappedList = grouped.entries.map((entry) {
      final firstTrack = entry.value.first;
      final albumName = entry.key;

      String tag = albumName.trim().isNotEmpty ? albumName.trim()[0].toUpperCase() : '#';
      if (!RegExp(r'[A-Z]').hasMatch(tag)) tag = '#';

      return AZAlbumItem(albumData: firstTrack, tag: tag, trackCount: entry.value.length);
    }).toList();

    SuspensionUtil.setShowSuspensionStatus(mappedList);
    azItms.value = mappedList;
  }

  void toggleSort(String category) {
    if (category == 'Album') {
      sortMode.value = (sortMode.value == SortMode.albumAsc) ? SortMode.albumDesc : SortMode.albumAsc;
    } else if (category == 'Artist') {
      sortMode.value = (sortMode.value == SortMode.artistAsc) ? SortMode.artistDesc : SortMode.artistAsc;
    }
  }
}
