import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/screens/widgets/coverArt.dart';

class AlbumTrackRow extends StatefulWidget {
  const AlbumTrackRow({super.key, required this.track, required this.onPressed, this.isWeb = false});

  final MediaItem track;
  final bool isWeb;
  final VoidCallback onPressed;

  @override
  State<AlbumTrackRow> createState() => _AlbumTrackRowState();
}

class _AlbumTrackRowState extends State<AlbumTrackRow> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    double size = 50.0;
    debugPrint("Extras: ${widget.track.extras}");

    return ListTile(
      onTap: widget.onPressed,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      leading: buildCoverArt(widget.track, size),

      title: Text(
        widget.track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.bodyLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        "${widget.track.artist ?? 'Unknown Artist'} • ${widget.track.extras!["trackNo"] ?? '#'}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
