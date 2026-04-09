import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/nav.dart';
import 'package:music_player/models/playlistTracks.dart';
import 'package:music_player/screens/widgets/miniPlayer.dart';
import 'package:music_player/screens/widgets/popupMenu.dart';

class PlaylistTracks extends StatefulWidget {
  const PlaylistTracks({super.key});

  @override
  State<PlaylistTracks> createState() => _PlaylistTracksState();
}

class _PlaylistTracksState extends State<PlaylistTracks> {
  late final PlaylistTracksViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = Get.put(PlaylistTracksViewModel());
  }

  @override
  void dispose() {
    if (Get.isRegistered<PlaylistTracksViewModel>()) {
      Get.delete<PlaylistTracksViewModel>();
    }
    super.dispose();
  }

  void _handleMenuSelection(int value, int index) {
    switch (value) {
      case 0:
        vm.playNext(index);
        break;
      case 1:
        vm.addToQueue(index);
        break;
      case 2:
        vm.removeEntryAt(index);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final bottomInset = kMiniPlayerHeight + MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          Obx(() {
            if (vm.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  expandedHeight: 180,
                  backgroundColor: scheme.surface,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                    title: Text(
                      vm.playlistName.value ?? 'Playlist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [scheme.secondaryContainer, scheme.surfaceContainerHighest],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(Icons.queue_music_rounded, size: 44, color: scheme.onSecondaryContainer),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow_rounded),
                      onPressed: vm.entries.isEmpty ? null : vm.playAll,
                      tooltip: 'Play',
                    ),
                    IconButton(
                      icon: const Icon(Icons.shuffle_rounded),
                      onPressed: vm.entries.isEmpty ? null : vm.shuffleAll,
                      tooltip: 'Shuffle',
                    ),
                    IconButton(
                      icon: const Icon(Icons.queue_music_rounded),
                      onPressed: vm.entries.isEmpty ? null : vm.addAllToQueue,
                      tooltip: 'Add to Queue',
                    ),
                  ],
                ),
                if (vm.entries.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.music_off_rounded, size: 56, color: scheme.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                              'No tracks in this playlist',
                              style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add tracks from albums, artists, or the library.',
                              textAlign: TextAlign.center,
                              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, bottomInset),
                    sliver: SliverList.builder(
                      itemCount: vm.entries.length,
                      itemBuilder: (context, index) {
                        final item = vm.entries[index];
                        final track = item.track;
                        final mediaItem = vm.toMediaItem(track);
                        final isCurrent = vm.currentTrackId.value == mediaItem.id && vm.currentIndex.value == index;

                        return ListTile(
                          onTap: () => vm.playFrom(index),
                          onLongPress: () => showModalBottomSheet(
                            context: context,
                            builder: (context) => PopupMenu(
                              longPress: true,
                              scheme: scheme,
                              items: const [
                                PopupMenuItemData(value: 0, icon: Icons.queue_music_rounded, label: 'Play Next'),
                                PopupMenuItemData(value: 1, icon: Icons.playlist_add_rounded, label: 'Add to Queue'),
                                PopupMenuItemData(
                                  value: 2,
                                  icon: Icons.remove_circle_outline_rounded,
                                  label: 'Remove from Playlist',
                                ),
                              ],
                              onSelected: (value) => _handleMenuSelection(value, index),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          tileColor: isCurrent ? scheme.primaryContainer.withValues(alpha: 0.3) : null,
                          leading: isCurrent
                              ? Icon(Icons.music_note_rounded, color: scheme.primary, size: 24)
                              : Text('${index + 1}', style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                          title: Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodyLarge?.copyWith(
                              color: isCurrent ? scheme.primary : scheme.onSurface,
                              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            track.artist ?? 'Unknown Artist',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          trailing: IconButton(
                            tooltip: 'Remove from playlist',
                            icon: const Icon(Icons.remove_circle_outline_rounded),
                            onPressed: () => vm.removeEntryAt(index),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }),
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
    );
  }
}
