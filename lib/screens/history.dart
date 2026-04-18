import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/history.dart';
import 'package:music_player/screens/widgets/trackRow.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final vm = Get.put(HistoryViewModel());
  final player = getIt<MusicService>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          'Track History',
          style: textTheme.titleLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
        ),
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(() {
            final hasItems = vm.groups.isNotEmpty;
            return IconButton(
              tooltip: 'Clear history',
              onPressed: hasItems ? vm.clearAll : null,
              icon: const Icon(Icons.delete_outline),
            );
          }),
        ],
      ),
      body: Obx(() {
        final groups = vm.groups;
        if (groups.isEmpty) {
          return Center(
            child: Text(
              'No plays yet.',
              style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16 + kToolbarHeight),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return _HistorySection(
              label: group.label,
              entries: group.items,
              onTapTrack: (entry) => player.playOne(entry.track),
            );
          },
        );
      }),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.label,
    required this.entries,
    required this.onTapTrack,
  });

  final String label;
  final List<HistoryEntry> entries;
  final void Function(HistoryEntry) onTapTrack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final timeFormat = DateFormat.jm();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
          child: Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...entries.map(
              (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: TrackRow(
              track: entry.track.toMediaItem(),
              onPressed: () => onTapTrack(entry),
              trailing: Text(
                timeFormat.format(entry.playedAt.toLocal()),
                style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
