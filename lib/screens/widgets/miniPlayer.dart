import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/screens/mainPlayer.dart';
import 'package:music_player/screens/widgets/trackCoverArt.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/PageManagerService.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerState = getIt<PlayerStateService>();
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<MediaItem?>(
      valueListenable: playerState.currentTrackNotifier,
      builder: (context, track, __) {
        if (track == null) return const SizedBox.shrink();

        return Dismissible(
          key: const Key('mini_player_down'),
          direction: DismissDirection.down,
          onDismissed: (_) {
            Feedback.forLongPress(context);
            playerState.stop();
          },
          child: Dismissible(
            key: ValueKey(track.id),
            confirmDismiss: (direction) {
              if (direction == DismissDirection.startToEnd) {
                playerState.prev();
              } else {
                playerState.next();
              }
              return Future.value(false);
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0 + MediaQuery.of(context).padding.bottom),
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                color: scheme.surfaceContainerHighest,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Get.generalDialog(
                      pageBuilder: (_, __, ___) => const MainPlayer(),
                      barrierDismissible: true,
                      barrierLabel: 'MainPlayer',
                      barrierColor: Colors.black54,
                      transitionDuration: const Duration(milliseconds: 150),
                      transitionBuilder: (context, animation, secondaryAnimation, child) {
                        final offset = Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

                        return SlideTransition(position: offset, child: child);
                      },
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MiniProgress(page: playerState),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: [
                            TrackCoverArt(track: track, size: 48.0),
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
                            _MiniControls(page: playerState),
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

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.page});

  final PlayerStateService page;

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

class _MiniControls extends StatelessWidget {
  const _MiniControls({required this.page});

  final PlayerStateService page;

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
