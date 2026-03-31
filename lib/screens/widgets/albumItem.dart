import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/albums.dart';
import 'package:music_player/screens/widgets/coverArt.dart';
import 'package:music_player/screens/widgets/gridItem.dart';

class AlbumItem extends StatelessWidget {
  const AlbumItem({super.key, required this.item, required this.onTap, this.isGrid = false});

  final AZAlbum item;
  final VoidCallback onTap;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final track = item.albumData.toMediaItem();
    const double size = 52.0;
    final albumTitle = track.album ?? "Unknown Album";
    final albumArtist = track.artist ?? "Unknown Artist";
    final tag = "album_art_${item.albumData.album}";

    if (isGrid) {
      return GridItem(
        onTap: onTap,
        title: albumTitle,
        subtitle: albumArtist,
        image: _AlbumArt(track: track, size: 96, tag: tag, isGrid: isGrid),
      );
    }

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _AlbumArt(track: track, size: size, tag: tag, isGrid: isGrid),
      title: Text(
        albumTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        albumArtist,
        maxLines: 1,
        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.track, required this.size, required this.tag, this.isGrid = false});

  final MediaItem track;
  final double size;
  final String tag;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isGrid ? 12 : 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: buildCoverArt(track, size),
      ),
    );
  }
}
