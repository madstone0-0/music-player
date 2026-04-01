import 'package:azlistview/azlistview.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/LocatorService.dart';

/// Flattened artist row produced by the DAO's GROUP BY query.
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
  final sortMode = SortMode.artistAsc.obs;
  final azItms = <AZArtist>[].obs;
  final isGrid = true.obs;

  @override
  void onInit() {
    super.onInit();
    ever(sortMode, (SortMode mode) => _bind(mode));
    ever(all, (_) => _buildAZList());
    _bind(sortMode.value);
  }

  void _bind(SortMode mode) {
    all.bindStream(
      repo
          .watchGroupedArtists(grouping: grouping, mode: mode)
          .map((rows) => rows.map((m) => ArtistData.fromMap(m, grouping)).toList()),
    );
  }

  void _buildAZList() {
    if (all.isEmpty) {
      azItms.value = [];
      return;
    }

    final snapshot = List<ArtistData>.of(all);

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

  void toggleSort(String category) {
    if (category == 'Name') {
      sortMode.value = sortMode.value == SortMode.artistAsc ? SortMode.artistDesc : SortMode.artistAsc;
    }
  }
}
