import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/tracks.dart'; // Adjust import if VM is moved
import 'package:music_player/screens/widgets/popupMenu.dart';
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

class _TracksState extends State<Tracks> with AutomaticKeepAliveClientMixin {
  final player = getIt<MusicService>();
  late final TracksViewModel vm;

  @override
  bool get wantKeepAlive => true;

  void _handleMenuSelection(int v, TrackData track) {
    switch (v) {
      case 0:
        player.playNext(track);
        break;
      case 1:
        player.addToQueue(track);
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    vm = Get.isRegistered<TracksViewModel>() ? Get.find<TracksViewModel>() : Get.put(TracksViewModel());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SortSection<TrackSortMode>(
            options: const [
              SortChipOption(label: 'Title', asc: TrackSortMode.titleAsc, desc: TrackSortMode.titleDesc),
              SortChipOption(label: 'Artist', asc: TrackSortMode.artistAsc, desc: TrackSortMode.artistDesc),
              SortChipOption(label: 'Album', asc: TrackSortMode.albumAsc, desc: TrackSortMode.albumDesc),
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
                    // On long press show a popup menu with options to add to queue, add to playlist, view album, view artist
                    onLongPress: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => PopupMenu(
                        longPress: true,
                        scheme: scheme,
                        items: [
                          PopupMenuItemData(value: 0, icon: Icons.queue_music_rounded, label: 'Play Next'),
                          PopupMenuItemData(value: 1, icon: Icons.playlist_add_rounded, label: 'Add to Queue'),
                          PopupMenuItemData(value: 2, icon: Icons.playlist_add_rounded, label: 'Add to Playlist'),
                          PopupMenuItemData(value: 3, icon: Icons.album_rounded, label: 'View Album'),
                          PopupMenuItemData(value: 4, icon: Icons.person_rounded, label: 'View Artist'),
                        ],
                        onSelected: (v) => _handleMenuSelection(v, item.track),
                      ),
                    ),
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
