import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/screens/widgets/coverArt.dart';

class AlbumTrackRow extends StatelessWidget {
  const AlbumTrackRow({super.key, required this.track, required this.onPressed, this.onLongPress});

  final MediaItem track;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    const double size = 50.0;
    final trackNo = track.extras?['trackNo'];

    return ListTile(
      onTap: onPressed,
      onLongPress: onLongPress,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      leading: buildCoverArt(track, size),

      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.bodyLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${track.artist ?? 'Unknown Artist'} • ${trackNo ?? '#'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
