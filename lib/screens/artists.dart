import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/nav.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/models/artists.dart';
import 'package:music_player/screens/artistAlbums.dart';
import 'package:music_player/screens/widgets/artistItem.dart';
import 'package:music_player/screens/widgets/azList.dart';
import 'package:music_player/screens/widgets/sort.dart';

class Artists extends StatefulWidget {
  const Artists({super.key, this.grouping = ArtistGrouping.artist});

  final ArtistGrouping grouping;

  @override
  State<Artists> createState() => _ArtistsState();
}

class _ArtistsState extends State<Artists> with AutomaticKeepAliveClientMixin {
  late final ArtistsViewModel vm;

  @override
  void initState() {
    super.initState();
    final tag = widget.grouping.name;
    vm = Get.isRegistered<ArtistsViewModel>(tag: tag)
        ? Get.find<ArtistsViewModel>(tag: tag)
        : Get.put(ArtistsViewModel(grouping: widget.grouping), tag: tag);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SortSection<SortMode>(
                  options: const [SortChipOption(label: 'Name', asc: SortMode.artistAsc, desc: SortMode.artistDesc)],
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
              () => AZList<AZArtist>(
                items: vm.azItms.value,
                gridCrossAxisCount: vm.isGrid.value ? 2 : 1,
                emptyMessage: 'No artists found, try scanning',
                itemBuilder: (context, item, index) {
                  return Padding(
                    padding: vm.isGrid.value ? const EdgeInsets.all(8.0) : AZList.itemPadding,
                    child: ArtistItem(
                      artist: item.artist,
                      isGrid: vm.isGrid.value,
                      onTap: () => Get.to(
                        () => ArtistAlbums(artistName: item.artist.name, grouping: widget.grouping),
                        // id: NESTED_NAV_ID,
                        transition: Transition.rightToLeftWithFade,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
