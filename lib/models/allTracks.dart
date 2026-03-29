import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/services/LocatorService.dart';

class AllTracksViewModel extends GetxController {
  final db = getIt<AppDatabase>();

  final allList = <TrackData>[].obs;
  final sortMode = SortMode.titleAsc.obs;

  @override
  void onInit() {
    super.onInit();
    ever(sortMode, (SortMode mode) {
      allList.bindStream(db.trackDao.watchAllTracks(mode: mode));
    });
    allList.bindStream(db.trackDao.watchAllTracks(mode: sortMode.value));
  }

  void toggleSort(String category) {
    switch (category) {
      case 'Title':
        sortMode.value = (sortMode.value == SortMode.titleAsc) ? SortMode.titleDesc : SortMode.titleAsc;
        break;
      case 'Artist':
        sortMode.value = (sortMode.value == SortMode.artistAsc) ? SortMode.artistDesc : SortMode.artistAsc;
        break;
      case 'Album':
        sortMode.value = (sortMode.value == SortMode.albumAsc) ? SortMode.albumDesc : SortMode.albumAsc;
        break;
    }
  }
}
