import 'package:audiotags/audiotags.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/services/AudioTaggingService.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';
import 'package:music_player/services/PlayerStateService.dart';

class MainPlayerViewModel extends GetxController {
  final currTag = Tag(pictures: []).obs;
  final playerState = getIt<PlayerStateService>();

  Picture? get coverArt => currTag.value.pictures.isNotEmpty ? currTag.value.pictures.first : null;

  @override
  void onInit() {
    super.onInit();
    playerState.currentTrackNotifier.addListener(() {
      final track = playerState.currentTrackNotifier.value;
      if (track != null) {
        _updateCurrentTag(track);
      } else {
        currTag.value = Tag(pictures: []);
      }
    });
  }

  Future<void> _updateCurrentTag(MediaItem track) async {
    final path = track.extras?['path'] ?? '';
    if (path.isNotEmpty) {
      final tag = await AudioTaggingService.readTag(path);
      if (tag != null) currTag.value = tag;
    } else {
      currTag.value = Tag(pictures: []);
    }
  }
}
