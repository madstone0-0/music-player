import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/LocatorService.dart';

enum ScanStatus { idle, scanning, done, error }

class ScanMediaViewModel extends GetxController {
  final TrackRepository _repo = getIt<TrackRepository>();

  final status = ScanStatus.idle.obs;
  final overwrite = false.obs;
  final currentIndex = 0.obs;
  final total = 0.obs;
  final currentPath = ''.obs;
  final errorMessage = ''.obs;
  final doneCount = 0.obs;

  double get progress => total.value == 0 ? 0.0 : (currentIndex.value / total.value).clamp(0.0, 1.0);

  bool get isScanning => status.value == ScanStatus.scanning;

  bool get isDone => status.value == ScanStatus.done;

  Future<void> startScan() async {
    status.value = ScanStatus.scanning;
    currentIndex.value = 0;
    total.value = 0;
    currentPath.value = '';
    errorMessage.value = '';
    doneCount.value = 0;

    // Debug log
    debugPrint('Starting media scan...');

    try {
      final scanned = await _repo.fullRescan(
        onProgress: (current, tot, path) {
          debugPrint('Scanning: $path ($current / $tot)');
          total.value = tot;
          currentIndex.value = current;
          currentPath.value = path;
        },
        overwrite: overwrite.value,
      );

      doneCount.value = scanned;
      status.value = ScanStatus.done;
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = ScanStatus.error;
    }
  }

  void reset() {
    status.value = ScanStatus.idle;
    currentIndex.value = 0;
    total.value = 0;
    currentPath.value = '';
    errorMessage.value = '';
    doneCount.value = 0;
  }
}
