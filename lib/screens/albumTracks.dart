import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/nav.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/albumTracks.dart';
import 'package:music_player/screens/widgets/albumTrackRow.dart';
import 'package:music_player/screens/widgets/miniPlayer.dart';
import 'package:music_player/screens/widgets/popupMenu.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

class AlbumTracks extends StatefulWidget {
  const AlbumTracks({super.key, this.grouping = ArtistGrouping.artist});

  final ArtistGrouping grouping;

  @override
  State<AlbumTracks> createState() => _AlbumTracksState();
}

class _AlbumTracksState extends State<AlbumTracks> {
  late final AlbumTracksViewModel vm;
  final player = getIt<MusicService>();

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
    }
  }

  @override
  void initState() {
    super.initState();
    vm = Get.put(AlbumTracksViewModel());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = kMiniPlayerHeight + MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          Obx(() {
            if (vm.tracks.isEmpty) {
              return Center(
                child: Text(
                  "No tracks found for this album",
                  style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final firstTrack = vm.tracks.first.toMediaItem();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: screenWidth,
                  pinned: true,
                  stretch: true,
                  backgroundColor: scheme.surface,
                  flexibleSpace: FlexibleSpaceBar(
                    // Left padding accounts for the pinned leading back button
                    // (~56 dp) so the title never overlaps it when collapsed.
                    titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                    title: Text(
                      vm.albumName ?? "Unknown Album",
                      style: text.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    background: _buildLargeArt(firstTrack.artUri, scheme),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow_rounded),
                      onPressed: () => player.playAll(vm.tracks),
                      tooltip: "Play",
                    ),
                    IconButton(
                      icon: const Icon(Icons.shuffle_rounded),
                      onPressed: () => player.playAll(vm.tracks, shuffle: true),
                      tooltip: "Shuffle",
                    ),
                    IconButton(
                      icon: const Icon(Icons.playlist_add_rounded),
                      onPressed: () {},
                      tooltip: "Add to Playlist",
                    ),
                    IconButton(
                      icon: const Icon(Icons.queue_music_rounded),
                      onPressed: () => player.addAllToQueue(vm.tracks),
                      tooltip: "Add to Queue",
                    ),
                  ],
                ),

                SliverPadding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, bottomInset),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final track = vm.tracks[index];
                      return AlbumTrackRow(
                        track: track.toMediaItem(),
                        onPressed: () => player.playAll(vm.tracks, index: index),
                        onLongPress: () => showModalBottomSheet(
                          context: context,
                          builder: (context) => PopupMenu(
                            longPress: true,
                            scheme: scheme,
                            items: [
                              PopupMenuItemData(value: 0, icon: Icons.queue_music_rounded, label: 'Play Next'),
                              PopupMenuItemData(value: 1, icon: Icons.playlist_add_rounded, label: 'Add to Queue'),
                              PopupMenuItemData(value: 2, icon: Icons.playlist_add_rounded, label: 'Add to Playlist'),
                            ],
                            onSelected: (v) => _handleMenuSelection(v, track),
                          ),
                        ),
                      );
                    }, childCount: vm.tracks.length),
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

  Widget _buildLargeArt(Uri? uri, ColorScheme scheme) {
    if (uri == null || uri.toFilePath().isEmpty) {
      return Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.album_rounded, size: 120, color: scheme.primary),
      );
    }

    return Hero(
      tag: 'album_art_${vm.albumName}',
      child: Image.file(
        File(uri.toFilePath()),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.album_rounded, size: 120, color: scheme.primary),
        ),
      ),
    );
  }
}
