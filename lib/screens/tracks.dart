import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/tracks.dart'; // Adjust import if VM is moved
import 'package:music_player/screens/widgets/allTracksRow.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

class Tracks extends StatefulWidget {
  const Tracks({super.key});

  @override
  State<Tracks> createState() => _TracksState();
}

class _TracksState extends State<Tracks> {
  final player = getIt<MusicService>();
  final vm = Get.put(TracksViewModel());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SortSection(vm: vm),

          Expanded(
            child: _TrackListAZ(vm: vm, player: player),
          ),
        ],
      ),
    );
  }
}

class _SortSection extends StatelessWidget {
  const _SortSection({required this.vm});

  final TracksViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Obx removed from here because the Row itself is static
      child: Row(
        children: [
          _SortChip(label: "Title", asc: SortMode.titleAsc, desc: SortMode.titleDesc, vm: vm),
          const SizedBox(width: 8),
          _SortChip(label: "Artist", asc: SortMode.artistAsc, desc: SortMode.artistDesc, vm: vm),
          const SizedBox(width: 8),
          _SortChip(label: "Album", asc: SortMode.albumAsc, desc: SortMode.albumDesc, vm: vm),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.label, required this.asc, required this.desc, required this.vm});

  final String label;
  final SortMode asc;
  final SortMode desc;
  final TracksViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Wrap only the part that depends on the observable
    return Obx(() {
      final isSelected = vm.sortMode.value == asc || vm.sortMode.value == desc;
      final isAsc = vm.sortMode.value == asc;

      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => vm.toggleSort(label),
        showCheckmark: false,
        selectedColor: scheme.secondaryContainer,
        backgroundColor: scheme.surface,
        avatar: isSelected
            ? Icon(
                isAsc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 18,
                color: scheme.onSecondaryContainer,
              )
            : null,
        labelStyle: text.labelLarge?.copyWith(
          color: isSelected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isSelected ? Colors.transparent : scheme.outlineVariant),
        ),
      );
    });
  }
}

class _TrackListAZ extends StatelessWidget {
  const _TrackListAZ({required this.vm, required this.player});

  final TracksViewModel vm;
  final MusicService player;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Obx(() {
      final list = vm.azItms.value;

      if (list.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return AzListView(
        data: list,
        itemCount: list.length,
        indexBarOptions: IndexBarOptions(
          needRebuild: true,
          selectTextStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
          selectItemDecoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
          indexHintAlignment: Alignment.centerRight,
          indexHintOffset: const Offset(-20, 0),
          textStyle: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
        ),
        indexHintBuilder: (context, hint) {
          return Container(
            alignment: Alignment.center,
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
            child: Text(
              hint,
              style: TextStyle(color: scheme.onPrimary, fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
          );
        },
        susItemBuilder: (context, index) {
          final tag = list[index].getSuspensionTag();
          return Container(
            height: 40,
            width: screenWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            color: scheme.surface,
            alignment: Alignment.centerLeft,
            child: Text(
              tag,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold),
            ),
          );
        },
        itemBuilder: (context, index) {
          final azItem = list[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0, right: 28.0),
            child: AllTrackRow(
              track: azItem.track.toMediaItem(),
              onPressed: () => player.play(vm.all.value, index: index),
            ),
          );
        },
      );
    });
  }
}
