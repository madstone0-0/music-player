import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/LocatorService.dart';

class AlbumTracksViewModel extends GetxController {

  final repo = getIt<TrackRepository>();

  final String? albumName = Get.arguments["album"] as String?;
  final String ? artistName = Get.arguments["artist"] as String?;

  final tracks = <TrackData>[].obs;

  @override
  void onInit() {
    super.onInit();
    tracks.bindStream(repo.watchByAlbumAndArtist(albumName, artistName));
  }
}
