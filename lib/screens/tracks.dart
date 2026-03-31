import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/tracks.dart'; // Adjust import if VM is moved
import 'package:music_player/screens/widgets/sort.dart';
import 'package:music_player/screens/widgets/trackRow.dart';
import 'package:music_player/screens/widgets/azList.dart';
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
          SortSection<SortMode>(
            options: const [
              SortChipOption(label: 'Title', asc: SortMode.titleAsc, desc: SortMode.titleDesc),
              SortChipOption(label: 'Artist', asc: SortMode.artistAsc, desc: SortMode.artistDesc),
              SortChipOption(label: 'Album', asc: SortMode.albumAsc, desc: SortMode.albumDesc),
            ],
            currentMode: vm.sortMode,
            onToggle: vm.toggleSort,
          ),

          Expanded(
            child: Obx(
              () => AZList<AZTrack>(
                items: vm.azItms.value,
                emptyMessage: 'No tracks found, try scanning',
                itemBuilder: (context, item, index) => Padding(
                  padding: AZList.itemPadding,
                  child: TrackRow(
                    track: item.track.toMediaItem(),
                    onPressed: () => player.playAll(vm.all.value, index: index),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
