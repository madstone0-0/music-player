import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/nav.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/albums.dart';
import 'package:music_player/screens/albumTracks.dart';
import 'package:music_player/screens/widgets/albumItem.dart';
import 'package:music_player/screens/widgets/sort.dart';
import 'package:music_player/screens/widgets/trackRow.dart';
import 'package:music_player/screens/widgets/azList.dart';
import 'package:music_player/screens/widgets/coverArt.dart';

class Albums extends StatefulWidget {
  const Albums({super.key});

  @override
  State<Albums> createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> with AutomaticKeepAliveClientMixin {
  _AlbumsState();

  late final AlbumsViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = Get.isRegistered<AlbumsViewModel>() ? Get.find<AlbumsViewModel>() : Get.put(AlbumsViewModel());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SortSection<SortMode>(
                  options: const [
                    SortChipOption(label: 'Title', asc: SortMode.albumAsc, desc: SortMode.albumDesc),
                    SortChipOption(label: 'Year', asc: SortMode.yearAsc, desc: SortMode.yearDesc),
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
                  padding: AZList.itemPadding,
                  child: AlbumItem(
                    item: item,
                    isGrid: vm.isGrid.value,
                    onTap: () => Get.to(
                      () => const AlbumTracks(),
                      // id: NESTED_NAV_ID,
                      arguments: {"album": item.albumData.album, "artist": item.albumData.artist},
                      transition: Transition.rightToLeftWithFade,
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
