import 'dart:async';
import 'package:azlistview/azlistview.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/LocatorService.dart';

class AZAlbum extends ISuspensionBean {
  final TrackData albumData;
  final String tag;
  final int trackCount;

  AZAlbum({required this.albumData, required this.tag, this.trackCount = 1});

  @override
  String getSuspensionTag() => tag;
}

class AlbumsViewModel extends GetxController {
  final repo = getIt<TrackRepository>();

  final azItms = <AZAlbum>[].obs;
  final sortMode = TrackSortMode.albumAsc.obs;
  final isGrid = false.obs;

  StreamSubscription? _albumSub;

  @override
  void onInit() {
    super.onInit();
    ever(sortMode, (_) => _fetchData());
    _fetchData();
  }

  void _fetchData() {
    _albumSub?.cancel();

    _albumSub = repo.watchGroupedAlbums(mode: sortMode.value).listen((groupedData) {
      if (groupedData.isEmpty) {
        azItms.value = [];
        return;
      }

      final isYearSort = sortMode.value == TrackSortMode.yearAsc || sortMode.value == TrackSortMode.yearDesc;
      final snapshot = List<Map<String, dynamic>>.of(groupedData);

      Future.microtask(() {
        if (isClosed) return;
        final List<AZAlbum> mappedList = groupedData.map((data) {
          final firstTrack = TrackData.fromJson(data);
          final albumName = firstTrack.album ?? "Unknown Album";
          final trackCount = data['trackCount'] as int;

          String tag;

          if (isYearSort) {
            final year = firstTrack.year;
            tag = year != null ? '${(year ~/ 10) * 10}s' : 'Unknown';
          } else {
            tag = albumName.trim().isNotEmpty ? albumName.trim()[0].toUpperCase() : '#';
            if (!RegExp(r'[A-Z]').hasMatch(tag)) tag = '#';
          }

          return AZAlbum(albumData: firstTrack, tag: tag, trackCount: trackCount);
        }).toList();

        SuspensionUtil.setShowSuspensionStatus(mappedList);
        if (!isClosed) azItms.value = mappedList;
      });
    });
  }

  @override
  void onClose() {
    _albumSub?.cancel();
    super.onClose();
  }

  void toggleSort(String category) {
    if (category == 'Title') {
      sortMode.value = (sortMode.value == TrackSortMode.albumAsc) ? TrackSortMode.albumDesc : TrackSortMode.albumAsc;
    } else if (category == 'Year') {
      sortMode.value = (sortMode.value == TrackSortMode.yearAsc) ? TrackSortMode.yearDesc : TrackSortMode.yearAsc;
    }
  }
}
