import 'package:azlistview/azlistview.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/LocatorService.dart';

/// Data class representing an artist, including the artist's name, track count, and optional cover image path.
class ArtistData {
  ArtistData({required this.name, required this.trackCount, this.coverPath});

  final String name;
  final int trackCount;
  final String? coverPath;

  factory ArtistData.fromMap(Map<String, dynamic> map, ArtistGrouping grouping) {
    final name = grouping == ArtistGrouping.artist
        ? (map['artist'] as String? ?? 'Unknown Artist')
        : (map['albumArtist'] as String? ?? 'Unknown Artist');
    return ArtistData(name: name, trackCount: (map['trackCount'] as int?) ?? 0, coverPath: map['coverPath'] as String?);
  }
}

/// AZList item implementation for artists, used for displaying artists in an A-Z list with suspension tags based on the first
/// letter of the artist's name.
class AZArtist extends ISuspensionBean {
  AZArtist({required this.artist, required this.tag});

  final ArtistData artist;
  final String tag;

  @override
  String getSuspensionTag() => tag;
}

class ArtistsViewModel extends GetxController {
  ArtistsViewModel({this.grouping = ArtistGrouping.artist});

  final ArtistGrouping grouping;
  final repo = getIt<TrackRepository>();

  final all = <ArtistData>[].obs;
  final sortMode = TrackSortMode.artistAsc.obs;
  final azItms = <AZArtist>[].obs;
  final isGrid = true.obs;

  @override
  void onInit() {
    super.onInit();
    ever(sortMode, (TrackSortMode mode) => _fetch(mode));
    ever(all, (_) => _buildAZList());
    _fetch(sortMode.value);
  }

  /// Fetches the list of artists from the repository based on the current sorting mode and grouping,
  /// and updates the `all` observable list with the retrieved data.
  void _fetch(TrackSortMode mode) {
    all.bindStream(
      repo
          .watchGroupedArtists(grouping: grouping, mode: mode)
          .map((rows) => rows.map((m) => ArtistData.fromMap(m, grouping)).toList()),
    );
  }

  /// Builds the A-Z list of artists for display in the UI. It maps each artist to an `AZArtist` instance,
  void _buildAZList() {
    if (all.isEmpty) {
      azItms.value = [];
      return;
    }

    // Use a microtask to ensure that the UI updates after the current event loop,
    // preventing potential issues with state updates during build.
    Future.microtask(() {
      if (isClosed) return;

      final mapped = all.map((artist) {
        String tag = artist.name.isNotEmpty ? artist.name[0].toUpperCase() : '#';
        if (!RegExp(r'[A-Z]').hasMatch(tag)) tag = '#';
        return AZArtist(artist: artist, tag: tag);
      }).toList();

      SuspensionUtil.setShowSuspensionStatus(mapped);

      if (!isClosed) azItms.value = mapped;
    });
  }

  /// Toggles the sorting mode for the artists based on the specified category. If the category is 'Name',
  void toggleSort(String category) {
    if (category == 'Name') {
      sortMode.value = sortMode.value == TrackSortMode.artistAsc ? TrackSortMode.artistDesc : TrackSortMode.artistAsc;
    }
  }
}
