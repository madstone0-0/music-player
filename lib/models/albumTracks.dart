import 'package:audiotags/audiotags.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/AudioTaggingService.dart';
import 'package:music_player/services/LocatorService.dart';

import '../db/tables/trackMapper.dart';

class AlbumTracksViewModel extends GetxController {
  final currFirstTag = Tag(pictures: []).obs;
  String? _lastPath;

  Picture? get firstCoverArt => currFirstTag.value.pictures.isNotEmpty ? currFirstTag.value.pictures.first : null;

  final repo = getIt<TrackRepository>();

  final String? albumName = Get.arguments["album"] as String?;
  final String? artistName = Get.arguments["artist"] as String?;

  final tracks = <TrackData>[].obs;

  @override
  void onInit() {
    super.onInit();
    tracks.bindStream(repo.watchByAlbumAndArtist(albumName, artistName));
    tracks.listen((ts) {
      if (ts.isEmpty) return;
      final firstTrack = ts.first;

      final currentPath = _lastPath;
      final newPath = firstTrack.toMediaItem().extras?['path'] ?? '';

      if (newPath != currentPath) {
        _lastPath = newPath;
        _updateCurrentTag(firstTrack.toMediaItem());
      }
    });
  }

  Future<void> _updateCurrentTag(MediaItem track) async {
    final path = track.extras?['path'] ?? '';
    if (path.isNotEmpty) {
      final tag = await AudioTaggingService.readTag(path);
      if (tag != null) currFirstTag.value = tag;
    } else {
      currFirstTag.value = Tag(pictures: []);
    }
  }
}
