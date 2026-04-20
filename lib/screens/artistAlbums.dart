import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player/screens/widgets/playlistModal.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/models/artistAlbums.dart';
import 'package:music_player/models/artists.dart';
import 'package:music_player/intents/queueIntent.dart';
import 'package:music_player/screens/albumTracks.dart';
import 'package:music_player/screens/widgets/miniPlayer.dart';
import 'package:music_player/screens/widgets/popupMenu.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

import '../common/nav.dart';
import '../intents/playlistModal.dart';

class ArtistAlbums extends StatefulWidget {
  const ArtistAlbums({super.key, required this.artistName, this.grouping = ArtistGrouping.artist});

  final String artistName;
  final ArtistGrouping grouping;

  @override
  State<ArtistAlbums> createState() => _ArtistAlbumsState();
}

class _ArtistAlbumsState extends State<ArtistAlbums> {
  late final ArtistAlbumsViewModel vm;
  final queueActions = QueueActionHandler();
  final _trackRepo = getIt<TrackRepository>();
  final _mscSrv = getIt<MusicService>();

  @override
  void initState() {
    super.initState();
    vm = Get.put(
      ArtistAlbumsViewModel(artistName: widget.artistName, grouping: widget.grouping),
      tag: '${widget.grouping.name}_${widget.artistName}',
    );
  }

  void _handleMenuSelection(int v, ArtistAlbumData albumData) async {
    final intent = QueueIntent.album(
      album: albumData.album,
      artist: widget.artistName,
      trackCount: albumData.trackCount,
    );

    switch (v) {
      case 0:
        final tracks = await intent.resolveTracks(_trackRepo);
        if (tracks.isNotEmpty) {
          await _mscSrv.playAll(tracks);
        }
        break;
      case 1:
        await queueActions.addToQueue(intent);
        break;
      case 2:
        PlaylistModal.open(
          context,
          PlaylistAddIntent.album(
            album: albumData.album,
            artist: widget.artistName,
            trackCount: albumData.trackCount,
          ),
        );
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
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Get.back()),
        title: Text(
          widget.artistName,
          style: text.titleLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Obx(() {
            final albums = vm.albums;

            if (albums.isEmpty) {
              return Center(
                child: Text('No albums found', style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: albums.length,
              itemBuilder: (context, index) => _AlbumCard(
                album: albums[index],
                onTap: () => Get.to(
                  () => const AlbumTracks(),
                  arguments: {"album": albums[index].album, "artist": widget.artistName},
                  transition: Transition.rightToLeftWithFade,
                ),
                onLongPress: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => PopupMenu(
                    longPress: true,
                    scheme: scheme,
                    items: [
                      PopupMenuItemData(value: 0, icon: Icons.play_arrow_rounded, label: 'Play'),
                      PopupMenuItemData(value: 1, icon: Icons.queue_music_rounded, label: 'Add to Queue'),
                      PopupMenuItemData(value: 2, icon: Icons.playlist_add_rounded, label: 'Add to Playlist'),
                    ],
                    onSelected: (v) =>
                        _handleMenuSelection(v, albums[index]),
                  ),
                ),
              ),
            );
          }),

          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album, required this.onTap, this.onLongPress});

  final ArtistAlbumData album;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _Artwork(coverPath: album.coverPath, scheme: scheme),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.album,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
          ),
          Text(
            [
              if (album.year != null) '${album.year}',
              '${album.trackCount} ${album.trackCount == 1 ? 'track' : 'tracks'}',
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.coverPath, required this.scheme});

  final String? coverPath;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    if (coverPath != null) {
      return Image.file(
        File(coverPath!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _Placeholder(scheme: scheme),
      );
    }
    return _Placeholder(scheme: scheme);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(child: Icon(Icons.album_outlined, size: 40, color: scheme.onSurfaceVariant.withValues(alpha: 0.4))),
    );
  }
}
