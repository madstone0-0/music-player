import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/models/artists.dart';
import 'package:music_player/services/LocatorService.dart';

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

class ArtistAlbumsViewModel extends GetxController {
  ArtistAlbumsViewModel({required this.artistName, required this.grouping});

  final String artistName;
  final ArtistGrouping grouping;
  final repo = getIt<TrackRepository>();

  final albums = <ArtistAlbumData>[].obs;

  @override
  void onInit() {
    super.onInit();
    albums.bindStream(
      repo
          .watchAlbumsByArtist(artistName, grouping: grouping)
          .map((rows) => rows.map(ArtistAlbumData.fromMap).toList()),
    );
  }
}
