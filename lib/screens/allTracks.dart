import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/tables/track_mapper.dart';
import 'package:music_player/models/allTracks.dart';
import 'package:music_player/screens/widgets/allTracksRow.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

class AllTracks extends StatefulWidget {
  const AllTracks({super.key});

  @override
  State<AllTracks> createState() => _AllTracksState();
}

class _AllTracksState extends State<AllTracks> {
  final vm = Get.put(AllTracksViewModel());
  final player = getIt<MusicService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Horizontal Sort Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Obx(
              () => Row(
                children: [
                  _buildSortChip("Title", SortMode.titleAsc, SortMode.titleDesc),
                  const SizedBox(width: 8),
                  _buildSortChip("Artist", SortMode.artistAsc, SortMode.artistDesc),
                  const SizedBox(width: 8),
                  _buildSortChip("Album", SortMode.albumAsc, SortMode.albumDesc),
                ],
              ),
            ),
          ),

          // List View
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: vm.allList.length,
                itemBuilder: (context, index) {
                  var track = vm.allList[index];
                  return AllTrackRow(
                    track: track.toMediaItem(),
                    onPressed: () => player.play(vm.allList, index: index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, SortMode asc, SortMode desc) {
    final isSelected = vm.sortMode.value == asc || vm.sortMode.value == desc;
    final isAsc = vm.sortMode.value == asc;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => vm.toggleSort(label),
      avatar: isSelected ? Icon(isAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 16) : null,
    );
  }
}
