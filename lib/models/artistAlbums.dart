import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/models/artists.dart';
import 'package:music_player/services/LocatorService.dart';

/// Data class representing an album by an artist, including the album name, track count, release year, and cover image path.
class ArtistAlbumData {
  ArtistAlbumData({required this.album, required this.trackCount, this.year, this.coverPath});

  final String album;
  final int trackCount;
  final int? year;
  final String? coverPath;

  factory ArtistAlbumData.fromMap(Map<String, dynamic> map) {
    return ArtistAlbumData(
      album: (map['album'] as String?) ?? 'Unknown Album',
      trackCount: (map['trackCount'] as int?) ?? 0,
      year: map['year'] as int?,
      coverPath: map['coverPath'] as String?,
    );
  }
}

/// ViewModel for managing the state of an artist's albums, including fetching album data from the repository and exposing it as an observable list.
/// The [grouping] parameter determines whether albums are grouped by artist or album artist
class ArtistAlbumsViewModel extends GetxController {
  ArtistAlbumsViewModel({required this.artistName, required this.grouping});

  final String artistName;
  final ArtistGrouping grouping;
  final repo = getIt<TrackRepository>();

  final albums = <ArtistAlbumData>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetch();
  }

  /// Fetches the albums for the specified artist from the repository and updates the observable list of albums.
  void _fetch() {
    albums.bindStream(
      repo
          .watchAlbumsByArtist(artistName, grouping: grouping)
          .map((rows) => rows.map(ArtistAlbumData.fromMap).toList()),
    );
  }
}
