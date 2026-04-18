import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/screens/widgets/coverArt.dart';
import 'package:music_player/screens/widgets/trackCoverArt.dart';

class TrackRow extends StatefulWidget {
  const TrackRow({super.key, required this.track, required this.onPressed, this.onLongPress, this.trailing});

  final MediaItem track;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  @override
  State<TrackRow> createState() => _TrackRowState();
}

class _TrackRowState extends State<TrackRow> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ListTile(
      onTap: widget.onPressed,
      onLongPress: widget.onLongPress,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      leading: TrackCoverArt(track: widget.track),

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
      trailing: widget.trailing,
    );
  }
}
