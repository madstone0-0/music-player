import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/albumTracks.dart';
import 'package:music_player/screens/widgets/albumTrackRow.dart';
import 'package:music_player/screens/widgets/miniPlayer.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

class AlbumTracks extends StatefulWidget {
  const AlbumTracks({super.key});

  @override
  State<AlbumTracks> createState() => _AlbumTracksState();
}

class _AlbumTracksState extends State<AlbumTracks> {
  late final AlbumTracksViewModel vm;
  final player = getIt<MusicService>();

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

    return Scaffold(
      backgroundColor: scheme.surface,
      // We use a Stack so the MiniPlayer can sit "on top" of the scrollable list
      body: Stack(
        children: [
          Obx(() {
            if (vm.tracks.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final firstTrack = vm.tracks.first.toMediaItem();

            return CustomScrollView(
              slivers: [
                // ─── Collapsing Header ────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: screenWidth,
                  pinned: true,
                  stretch: true,
                  backgroundColor: scheme.surface,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(vm.albumName, style: text.titleMedium),
                    background: _buildLargeArt(firstTrack.artUri, scheme),
                  ),
                ),

                // ─── Track List ───────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // Added 80px bottom padding
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final track = vm.tracks[index];
                      return AlbumTrackRow(
                        track: track.toMediaItem(),
                        onPressed: () => player.play(vm.tracks, index: index),
                      );
                    }, childCount: vm.tracks.length),
                  ),
                ),
              ],
            );
          }),

          // ─── The Mini Player ───────────────────────────────────────────────
          // Positioned at the bottom of the screen
          // const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
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
