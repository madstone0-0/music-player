import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/screens/mainPlayer.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/PageManagerService.dart';

class MiniPlayerView extends StatelessWidget {
  const MiniPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final page = getIt<PageManagerService>();
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<MediaItem?>(
      valueListenable: page.currentTrackNotifier,
      builder: (context, track, __) {
        if (track == null) return const SizedBox.shrink();

        return Dismissible(
          key: const Key('mini_player_down'),
          direction: DismissDirection.down,
          onDismissed: (_) {
            Feedback.forLongPress(context);
            page.stop();
          },
          child: Dismissible(
            key: ValueKey(track.id),
            confirmDismiss: (direction) {
              if (direction == DismissDirection.startToEnd) {
                page.previous();
              } else {
                page.next();
              }
              return Future.value(false);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                // M3 standard for secondary floating elements
                color: scheme.surfaceContainerHighest,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(opaque: false, pageBuilder: (_, __, ___) => const MainPlayer()),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Edge-to-edge Progress ─────────────────────────────
                      _MiniProgress(page: page),

                      // ── Track Info & Controls ─────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: [
                            _TrackArtwork(track: track),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    track.artist ?? 'Unknown Artist',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            _MiniControls(page: page),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Edge-to-edge Progress ───────────────────────────────────────────────────

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.page});

  final PageManagerService page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: page.progressNotifier,
      builder: (context, state, __) {
        final position = state.current.inSeconds.toDouble();
        final total = state.total.inSeconds.toDouble();

        if (total <= 0 || position < 0 || position > total) {
          return const SizedBox.shrink();
        }

        // Using LinearProgressIndicator for a cleaner M3 mini-player look,
        // as scrubbing is usually reserved for the main player.
        return LinearProgressIndicator(
          value: position / total,
          minHeight: 2.0,
          backgroundColor: Colors.transparent,
          color: scheme.primary,
        );
      },
    );
  }
}

// ─── Playback Controls ────────────────────────────────────────────────────────

class _MiniControls extends StatelessWidget {
  const _MiniControls({required this.page});

  final PageManagerService page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<ButtonState>(
      valueListenable: page.playButtonNotifier,
      builder: (context, state, _) {
        final isPlaying = state == ButtonState.playing;
        final isLoading = state == ButtonState.loading;

        if (isLoading) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
            ),
          );
        }

        return IconButton(
          iconSize: 32,
          color: scheme.onSurface,
          icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
          onPressed: isPlaying ? page.pause : page.play,
        );
      },
    );
  }
}

// ─── Track artwork (Vinyl Style) ──────────────────────────────────────────────

class _TrackArtwork extends StatelessWidget {
  const _TrackArtwork({required this.track});

  final MediaItem track;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Safer check for valid file paths
    final path = track.artUri?.toFilePath();
    final hasArtwork = path != null && path.isNotEmpty;

    return Hero(
      tag: 'currentArtwork',
      child: SizedBox.square(
        dimension: 48.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Artwork image
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: hasArtwork
                  ? Image.file(
                      File(path!),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(scheme),
                    )
                  : _placeholder(scheme),
            ),

            // Vinyl ring overlay
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: scheme.onSurface.withOpacity(0.1), width: 1),
                borderRadius: BorderRadius.circular(24),
              ),
            ),

            // Centre hole (blends with Card background)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) {
    return Container(
      width: 48,
      height: 48,
      color: scheme.surfaceContainer,
      child: Icon(Icons.music_note_rounded, color: scheme.onSurfaceVariant),
    );
  }
}
