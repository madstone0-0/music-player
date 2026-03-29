import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/screens/widgets/coverArt.dart';

class AllTrackRow extends StatefulWidget {
  const AllTrackRow({super.key, required this.track, required this.onPressed, this.isWeb = false});

  final MediaItem track;
  final bool isWeb;
  final VoidCallback onPressed;

  @override
  State<AllTrackRow> createState() => _AllTrackRowState();
}

class _AllTrackRowState extends State<AllTrackRow> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ListTile(
      onTap: widget.onPressed,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      leading: _VinylAlbumArt(track: widget.track, isWeb: widget.isWeb),

      title: Text(
        widget.track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.bodyLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        widget.track.artist ?? "Unknown Artist",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _VinylAlbumArt extends StatelessWidget {
  const _VinylAlbumArt({required this.track, required this.isWeb});

  final MediaItem track;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const double size = 50.0;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: buildCoverArt(track, size, scheme: scheme, isWeb: isWeb),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(color: scheme.onSurface.withOpacity(0.1), width: 1),
              borderRadius: BorderRadius.circular(size / 2),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(6)),
          ),
        ],
      ),
    );
  }
}
