import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/albums.dart';
import 'package:music_player/screens/albumTracks.dart';
import 'package:music_player/screens/widgets/albumRow.dart';
import 'package:music_player/screens/widgets/allTracksRow.dart';
import 'package:music_player/screens/widgets/coverArt.dart'; // We can reuse the Vinyl Art component

class Albums extends StatefulWidget {
  const Albums({super.key});

  @override
  State<Albums> createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> {
  final vm = Get.put(AlbumsViewModel());

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
        children: [
          _AlbumSortSection(vm: vm),
          Expanded(child: _AlbumListAZ(vm: vm)),
        ],
      ),
    );
  }
}

class _AlbumListAZ extends StatelessWidget {
  const _AlbumListAZ({required this.vm});

  final AlbumsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Obx(() {
      final list = vm.azItms.value;
      if (list.isEmpty) return const Center(child: CircularProgressIndicator());

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
          return Padding(
            padding: const EdgeInsets.only(right: 28.0),
            child: AlbumRow(
              item: list[index],
              onTap: () {
                Get.to(
                  () => const AlbumTracks(),
                  arguments: list[index].albumData.album ?? "Unknown Album",
                  transition: Transition.rightToLeftWithFade, // M3 style transition
                );
              },
            ),
          );
        },
      );
    });
  }
}

class _AlbumSortSection extends StatelessWidget {
  const _AlbumSortSection({required this.vm});

  final AlbumsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          _AlbumSortChip(label: "Album", asc: SortMode.albumAsc, desc: SortMode.albumDesc, vm: vm),
          const SizedBox(width: 8),
          _AlbumSortChip(label: "Artist", asc: SortMode.artistAsc, desc: SortMode.artistDesc, vm: vm),
        ],
      ),
    );
  }
}

class _AlbumSortChip extends StatelessWidget {
  const _AlbumSortChip({required this.label, required this.asc, required this.desc, required this.vm});

  final String label;
  final SortMode asc;
  final SortMode desc;
  final AlbumsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final isSelected = vm.sortMode.value == asc || vm.sortMode.value == desc;
      final isAsc = vm.sortMode.value == asc;
      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => vm.toggleSort(label),
        showCheckmark: false,
        avatar: isSelected ? Icon(isAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 18) : null,
        selectedColor: scheme.secondaryContainer,
      );
    });
  }
}
