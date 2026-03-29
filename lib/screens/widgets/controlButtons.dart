import 'package:flutter/material.dart';
import 'package:music_player/common/color.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/PageManagerService.dart';

class PrimaryContols extends StatelessWidget {
  const PrimaryContols({super.key, required this.page});

  final PageManagerService page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Previous.
        ValueListenableBuilder<bool>(
          valueListenable: page.isFirstTrackNotifier,
          builder: (context, isFirst, _) => IconButton(
            onPressed: isFirst ? null : page.previous,
            iconSize: 32,
            color: isFirst ? scheme.onSurface.withOpacity(0.3) : scheme.onSurface,
            icon: const Icon(Icons.skip_previous_rounded),
          ),
        ),

        const SizedBox(width: 8),

        // Play / Pause — M3 FilledButton gives the branded filled circle.
        ValueListenableBuilder<ButtonState>(
          valueListenable: page.playButtonNotifier,
          builder: (context, state, _) {
            final isLoading = state == ButtonState.loading;
            final isPlaying = state == ButtonState.playing;

            return SizedBox.square(
              dimension: 72,
              child: FilledButton(
                onPressed: isLoading ? null : (isPlaying ? page.pause : page.play),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                ),
                child: isLoading
                    ? SizedBox.square(
                  dimension: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: scheme.onPrimary),
                )
                    : Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 36),
              ),
            );
          },
        ),

        const SizedBox(width: 8),

        // Next.
        ValueListenableBuilder<bool>(
          valueListenable: page.isLastTrackNotifier,
          builder: (context, isLast, _) => IconButton(
            onPressed: isLast ? null : page.next,
            iconSize: 32,
            color: isLast ? scheme.onSurface.withOpacity(0.3) : scheme.onSurface,
            icon: const Icon(Icons.skip_next_rounded),
          ),
        ),
      ],
    );
  }
}

class SecondaryControls extends StatelessWidget {
  const SecondaryControls({super.key, required this.page});

  final PageManagerService page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle — FilledTonal when active, standard when inactive.
        ValueListenableBuilder<bool>(
          valueListenable: page.isShuffleEnabledNotifier,
          builder: (context, enabled, _) => _SecondaryButton(
            icon: Icons.shuffle_rounded,
            label: 'Shuffle',
            active: enabled,
            onTap: page.toggleShuffle,
          ),
        ),

        // Repeat — cycles off → all → one.
        ValueListenableBuilder<RepeatState>(
          valueListenable: page.repeatButtonNotifier,
          builder: (context, state, _) => _SecondaryButton(
            icon: state == RepeatState.repeatSong ? Icons.repeat_one_rounded : Icons.repeat_rounded,
            label: 'Repeat',
            active: state != RepeatState.off,
            onTap: page.toggleRepeat,
          ),
        ),

        // Queue.
        _SecondaryButton(
          icon: Icons.queue_music_rounded,
          label: 'Queue',
          active: false,
          onTap: () {
            // openPlayPlaylistQueue();
          },
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.icon, required this.label, required this.active, required this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // FilledTonal for active state, plain icon otherwise.
          active
              ? FilledButton.tonal(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
            ),
            child: Icon(icon, size: 22),
          )
              : IconButton(onPressed: onTap, iconSize: 22, color: scheme.onSurfaceVariant, icon: Icon(icon)),
          Text(label, style: text.labelSmall?.copyWith(color: active ? scheme.primary : scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class MoreMenu extends StatelessWidget {
  const MoreMenu({super.key, required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: scheme.surfaceContainerHigh,
      elevation: 2,
      offset: const Offset(-8, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: Icon(Icons.more_vert_rounded, color: scheme.onSurface),
      onSelected: (value) {
        switch (value) {
          case 1:
          /* open queue */
            break;
          case 2:
          /* add playlist */
            break;
          case 3:
          /* lyrics */
            break;
          case 4:
          /* details */
            break;
        }
      },
      itemBuilder: (_) => [
        _menuItem(1, Icons.queue_music_rounded, 'Playing queue'),
        _menuItem(2, Icons.playlist_add_rounded, 'Add to playlist'),
        _menuItem(3, Icons.lyrics_outlined, 'Lyrics'),
        _menuItem(4, Icons.info_outline_rounded, 'Details'),
      ],
    );
  }

  PopupMenuItem<int> _menuItem(int value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: scheme.onSurface, fontSize: 13)),
        ],
      ),
    );
  }
}

