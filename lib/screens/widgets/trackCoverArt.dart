import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/screens/widgets/coverArt.dart';

enum CoverStyle { circular, rounded, square, vinyl }

class TrackCoverArt extends StatelessWidget {
  const TrackCoverArt({super.key, required this.track, this.size = 50.0, this.style = CoverStyle.rounded, this.coverArtOverride});

  final MediaItem? track;
  final double size;
  final CoverStyle style;
  final Widget? coverArtOverride;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final Widget baseArtwork = coverArtOverride ?? buildCoverArt(track, size, scheme: scheme);

    switch (style) {
      case CoverStyle.square:
        return SizedBox.square(dimension: size, child: baseArtwork);

      case CoverStyle.rounded:
        return SizedBox.square(
          dimension: size,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: baseArtwork,
          ),
        );

      case CoverStyle.circular:
        return SizedBox.square(
          dimension: size,
          child: ClipRRect(borderRadius: BorderRadius.circular(size / 2), child: baseArtwork),
        );

      case CoverStyle.vinyl:
        return SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(size / 2), child: baseArtwork),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.onSurface.withValues(alpha: 0.1), width: 1),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: size * 0.24,
                height: size * 0.24,
                decoration: BoxDecoration(color: scheme.surface, shape: BoxShape.circle),
              ),
            ],
          ),
        );
    }
  }
}
