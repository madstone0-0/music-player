import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/albums.dart';
import 'package:music_player/screens/widgets/coverArt.dart';

class AlbumRow extends StatelessWidget {
  final AZAlbumItem item;
  final VoidCallback onTap;

  const AlbumRow({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final track = item.albumData.toMediaItem();
    const double size = 50.0;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Hero(
        tag: "album_art_${item.albumData.album}",
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: scheme.surfaceContainerHighest),
          clipBehavior: Clip.antiAlias,
          child: buildCoverArt(track, size),
        ),
      ),
      title: Text(
        track.album ?? "Unknown Album",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        track.artist ?? 'Unknown Artist',
        maxLines: 1,
        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
