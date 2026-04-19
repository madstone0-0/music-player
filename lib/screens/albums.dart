import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/models/albums.dart';
import 'package:music_player/intents/queueIntent.dart';
import 'package:music_player/screens/albumTracks.dart';
import 'package:music_player/screens/widgets/playlistModal.dart';
import 'package:music_player/screens/widgets/albumItem.dart';
import 'package:music_player/screens/widgets/popupMenu.dart';
import 'package:music_player/screens/widgets/sort.dart';
import 'package:music_player/screens/widgets/azList.dart';

import '../models/playlistModal.dart';

class Albums extends StatefulWidget {
  const Albums({super.key});

  @override
  State<Albums> createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> with AutomaticKeepAliveClientMixin {
  _AlbumsState();

  late final AlbumsViewModel vm;
  final queueActions = QueueActionHandler();

  @override
  void initState() {
    super.initState();
    vm = Get.isRegistered<AlbumsViewModel>() ? Get.find<AlbumsViewModel>() : Get.put(AlbumsViewModel());
  }

  void _handleMenuSelection(int v, TrackData albumData, int trackCount) async {
    final intent = QueueIntent.album(
      album: albumData.album,
      artist: albumData.artist,
      trackCount: trackCount,
    );

    switch (v) {
      case 0:
        await queueActions.playNext(intent);
        break;
      case 1:
        await queueActions.addToQueue(intent);
        break;
      case 2:
        PlaylistModal.open(
          context,
          PlaylistAddIntent.album(album: albumData.album, artist: albumData.artist, trackCount: trackCount),
        );
        break;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SortSection<TrackSortMode>(
                  options: const [
                    SortChipOption(label: 'Title', asc: TrackSortMode.albumAsc, desc: TrackSortMode.albumDesc),
                    SortChipOption(label: 'Year', asc: TrackSortMode.yearAsc, desc: TrackSortMode.yearDesc),
                  ],
                  currentMode: vm.sortMode,
                  onToggle: vm.toggleSort,
                ),
              ),
              Obx(
                () => IconButton(
                  icon: Icon(vm.isGrid.value ? Icons.view_list_rounded : Icons.grid_view_rounded),
                  color: scheme.onSurfaceVariant,
                  onPressed: () => vm.isGrid.toggle(),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),

          Expanded(
            child: Obx(
              () => AZList<AZAlbum>(
                items: vm.azItms.value,
                gridCrossAxisCount: vm.isGrid.value ? 2 : 1,
                emptyMessage: 'No albums found, try scanning',
                itemBuilder: (context, item, index) => Padding(
                  padding: vm.isGrid.value ? const EdgeInsets.all(8.0) : AZList.itemPadding,
                  child: AlbumItem(
                    item: item,
                    isGrid: vm.isGrid.value,
                    onTap: () => Get.to(
                      () => const AlbumTracks(),
                      // id: NESTED_NAV_ID,
                      arguments: {"album": item.albumData.album, "artist": item.albumData.artist},
                      transition: Transition.rightToLeftWithFade,
                    ),
                    onLongPress: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => PopupMenu(
                        items: [
                          PopupMenuItemData(value: 0, icon: Icons.queue_music_rounded, label: 'Play Next'),
                          PopupMenuItemData(value: 1, icon: Icons.playlist_add_rounded, label: 'Add to Queue'),
                          PopupMenuItemData(value: 2, icon: Icons.playlist_add_rounded, label: 'Add to Playlist'),
                        ],
                        onSelected: (v) => _handleMenuSelection(v, item.albumData, item.trackCount),
                        longPress: true,
                        scheme: scheme,
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
