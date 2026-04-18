import 'dart:async';

import 'package:get/get.dart';
import 'package:music_player/db/daos/history.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/history.dart';
import 'package:music_player/db/tables/track.dart';
import 'package:music_player/services/LocatorService.dart';

class HistoryEntry {
  HistoryEntry({required this.track, required this.playedAt});

  final TrackData track;
  final DateTime playedAt;
}

class HistoryGroup {
  HistoryGroup({required this.label, required this.items});

  final String label;
  final List<HistoryEntry> items;
}

class HistoryViewModel extends GetxController {
  final HistoryRepository repo = getIt<HistoryRepository>();

  final groups = <HistoryGroup>[].obs;
  StreamSubscription<List<HistoryWithTrack>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = repo.watchAllWithTracks().listen((entries) {
      if (isClosed) return;
      groups.value = _group(entries);
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> clearAll() => repo.clearAll();

  List<HistoryGroup> _group(List<HistoryWithTrack> entries) {
    if (entries.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<HistoryEntry>> buckets = {};

    for (final e in entries) {
      final local = e.entry.playedAt.toLocal();
      final dateKey = DateTime(local.year, local.month, local.day);

      final String label;
      if (_isSameDay(dateKey, today)) {
        label = 'Today';
      } else if (_isSameDay(dateKey, yesterday)) {
        label = 'Yesterday';
      } else {
        label = _formatDateKey(dateKey);
      }

      final list = buckets.putIfAbsent(label, () => []);
      list.add(HistoryEntry(track: e.track, playedAt: e.entry.playedAt));
    }

    final orderedLabels = <String>[];
    for (final e in entries) {
      final local = e.entry.playedAt.toLocal();
      final dateKey = DateTime(local.year, local.month, local.day);
      final String label;
      if (_isSameDay(dateKey, today)) {
        label = 'Today';
      } else if (_isSameDay(dateKey, yesterday)) {
        label = 'Yesterday';
      } else {
        label = _formatDateKey(dateKey);
      }
      if (!orderedLabels.contains(label)) {
        orderedLabels.add(label);
      }
    }

    return orderedLabels
        .map((label) => HistoryGroup(label: label, items: buckets[label] ?? const []))
        .toList(growable: false);
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateKey(DateTime d) => '${_monthName(d.month)} ${d.day}, ${d.year}';

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[(month - 1).clamp(0, months.length - 1)];
  }
}
