import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

class TrackDetails extends StatelessWidget {
  const TrackDetails({super.key, required this.track});

  final MediaItem track;

  static Future<void> show(BuildContext context, MediaItem track) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => TrackDetails(track: track),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final extras = track.extras ?? {};
    final trackNo = extras['trackNo'] as int?;
    final year = extras['year'] as int?;
    final albumArtist = extras['albumArtist'] as String?;
    final path = extras['path'] as String?;
    final duration = track.duration;

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85, // controls max height of sheet
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Track Details',
                style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _detailRow(context, 'Title', track.title),
              _detailRow(context, 'Artist', track.artist ?? 'Unknown Artist'),
              if (albumArtist != null && albumArtist.isNotEmpty) _detailRow(context, 'Album Artist', albumArtist),
              _detailRow(context, 'Album', track.album ?? 'Unknown Album'),
              if (year != null) _detailRow(context, 'Year', '$year'),
              if (trackNo != null) _detailRow(context, 'Track #', '$trackNo'),
              if (duration != null) _detailRow(context, 'Duration', _fmtDuration(duration)),
              if (track.genre != null && track.genre!.isNotEmpty) _detailRow(context, 'Genre', track.genre!),
              if (path != null && path.isNotEmpty) _detailRow(context, 'File', path),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: text.bodyMedium?.copyWith(color: scheme.onSurface),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    final hours = d.inHours;

    if (hours > 0) {
      final mins = minutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
