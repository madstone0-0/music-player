import 'package:azlistview/azlistview.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/LocatorService.dart';

/// AZList item implementation for TrackData, used for displaying tracks in an indexed list with headers.
class AZTrack extends ISuspensionBean {
  final TrackData track;
  final String tag;

  AZTrack({required this.track, required this.tag});

  @override
  String getSuspensionTag() => tag;
}

class TracksViewModel extends GetxController {
  final repo = getIt<TrackRepository>();

  final all = <TrackData>[].obs;
  final sortMode = TrackSortMode.titleAsc.obs;
  final azItms = <AZTrack>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Watch for changes in the sorting mode and update the track list accordingly
    ever(sortMode, (TrackSortMode mode) {
      all.bindStream(repo.watchAll(mode: mode));
    });
    // Watch for changes in the track list and regenerate the AZTrack items for the indexed list
    ever(all, (_) => _generateAZItm());
    _fetch();
  }

  /// Fetches the track data from the repository based on the current sorting mode and updates the observable list.
  void _fetch() {
    all.bindStream(repo.watchAll(mode: sortMode.value));
  }

  /// Generates the list of AZTrack items for the indexed list view based on the current track data and sorting mode.
  void _generateAZItm() {
    if (all.isEmpty) {
      azItms.value = [];
      return;
    }

    final snapshot = List<TrackData>.of(all);
    final mode = sortMode.value;

    Future.microtask(() {
      if (isClosed) return;

      final List<AZTrack> mappedList = snapshot.map((track) {
        String rawString = '';

        // Determine which field to extract the first letter from
        if (mode == TrackSortMode.artistAsc || mode == TrackSortMode.artistDesc) {
          rawString = track.artist ?? 'Unknown Artist';
        } else if (mode == TrackSortMode.albumAsc || mode == TrackSortMode.albumDesc) {
          rawString = track.album ?? 'Unknown Album';
        } else {
          rawString = track.title;
        }

        String tag = rawString.isNotEmpty ? rawString[0].toUpperCase() : '#';
        if (!RegExp(r'[A-Z]').hasMatch(tag)) {
          tag = '#';
        }

        return AZTrack(track: track, tag: tag);
      }).toList();

      SuspensionUtil.setShowSuspensionStatus(mappedList);
      if (!isClosed) azItms.value = mappedList;
    });
  }

  /// Toggles the sorting mode for the specified category (Title, Artist, or Album) between ascending and descending order.
  void toggleSort(String category) {
    switch (category) {
      case 'Title':
        sortMode.value = (sortMode.value == TrackSortMode.titleAsc) ? TrackSortMode.titleDesc : TrackSortMode.titleAsc;
        break;
      case 'Artist':
        sortMode.value = (sortMode.value == TrackSortMode.artistAsc)
            ? TrackSortMode.artistDesc
            : TrackSortMode.artistAsc;
        break;
      case 'Album':
        sortMode.value = (sortMode.value == TrackSortMode.albumAsc) ? TrackSortMode.albumDesc : TrackSortMode.albumAsc;
        break;
    }
  }
}
