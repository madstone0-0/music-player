import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/models/lyrics.dart';
import 'package:music_player/screens/widgets/trackCoverArt.dart';

class LyricsDisplay extends StatefulWidget {
  const LyricsDisplay({super.key, required this.track});

  final MediaItem track;

  @override
  State<LyricsDisplay> createState() => _LyricsDisplayState();
}

class _LyricsDisplayState extends State<LyricsDisplay> {
  late final LyricsViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = Get.put(LyricsViewModel(initialTrack: widget.track));
  }

  @override
  void dispose() {
    Get.delete<LyricsViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'Lyrics',
          style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
        ),
        actions: [
          Obx(() {
            final loading = vm.status.value == LyricsStatus.loading;
            return IconButton(
              tooltip: 'Reload lyrics',
              onPressed: loading ? null : vm.refresh,
              icon: const Icon(Icons.refresh_rounded),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final track = vm.track.value;
          final lyrics = vm.lyrics.value;
          final status = vm.status.value;
          final isSynced = lyrics?.isSynced ?? false;

          return Column(
            children: [
              _TrackSummary(
                track: track,
                status: status,
                isSynced: isSynced,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: switch (status) {
                    LyricsStatus.loading => const _LoadingState(key: ValueKey('loading')),
                    LyricsStatus.empty => _EmptyState(
                        key: const ValueKey('empty'), onRetry: track == null ? null : vm.refresh),
                    LyricsStatus.ready => _LyricsBody(
                      key: const ValueKey('ready'),
                      controller: vm.lyrCon,
                      isSynced: isSynced,
                      buildStyle: isSynced ? _syncedStyle : _plainStyle,
                    ),
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  LyricStyle _syncedStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final inactiveColor = scheme.onSurface;
    final activeColor = scheme.primary;

    return LyricStyle(
      textStyle: text.bodyLarge?.copyWith(
        color: inactiveColor,
        height: 1.55,
        fontWeight: FontWeight.w400,
      ) ??
          TextStyle(color: inactiveColor, fontSize: 15, height: 1.55),
      activeStyle: text.titleLarge?.copyWith(
        color: activeColor,
        fontWeight: FontWeight.w700,
        height: 1.45,
        fontSize: 20,
      ) ??
          TextStyle(color: activeColor, fontSize: 20, fontWeight: FontWeight.w700, height: 1.45),
      translationStyle: text.bodyMedium?.copyWith(
        color: inactiveColor,
        height: 1.3,
      ) ??
          TextStyle(color: inactiveColor, fontSize: 14, height: 1.3),

      lineTextAlign: TextAlign.center,
      contentAlignment: CrossAxisAlignment.center,

      lineGap: 26,
      translationLineGap: 8,

      contentPadding: const EdgeInsets.fromLTRB(24, 36, 24, 36),

      selectionAnchorPosition: 0.38,
      activeAnchorPosition: 0.38,

      selectionAlignment: MainAxisAlignment.center,

      fadeRange: FadeRange(top: 72, bottom: 72),

      scrollDuration: const Duration(milliseconds: 300),
      scrollDurations: {
        400: const Duration(milliseconds: 340),
        800: const Duration(milliseconds: 480),
      },

      selectionAutoResumeDuration: const Duration(milliseconds: 600),
      activeAutoResumeDuration: const Duration(milliseconds: 2000),

      selectedColor: activeColor,
      selectedTranslationColor: activeColor,

      activeHighlightColor: scheme.primary,
      activeHighlightGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          scheme.primary,
          scheme.secondary,
          scheme.tertiary,
        ],
      ),
      activeHighlightExtraFadeWidth: 16,
    );
  }

  LyricStyle _plainStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final base = text.bodyLarge?.copyWith(
      color: scheme.onSurface,
      height: 1.6,
    ) ??
        TextStyle(color: scheme.onSurface, fontSize: 15, height: 1.6);

    return LyricStyle(
      textStyle: base,
      activeStyle: base,
      translationStyle: base,

      lineTextAlign: TextAlign.left,
      contentAlignment: CrossAxisAlignment.start,

      lineGap: 16,
      translationLineGap: 0,

      contentPadding: const EdgeInsets.fromLTRB(18, 24, 18, 24),

      selectionAnchorPosition: 0.0,
      activeAnchorPosition: 0.0,

      selectionAlignment: MainAxisAlignment.start,

      fadeRange: FadeRange(top: 0, bottom: 0),

      scrollDuration: const Duration(milliseconds: 180),

      selectionAutoResumeDuration: const Duration(milliseconds: 300),
      activeAutoResumeDuration: const Duration(milliseconds: 800),

      selectedColor: scheme.onSurface,
      selectedTranslationColor: scheme.onSurface,

      activeHighlightColor: scheme.onSurface.withValues(alpha: 0.04),
      activeHighlightGradient: LinearGradient(
        colors: [
          scheme.onSurface.withValues(alpha: 0.02),
          scheme.onSurface.withValues(alpha: 0.06),
        ],
      ),

      enableSwitchAnimation: false,

      activeLineOnly: false,
      disableTouchEvent: true,
    );
  }

}

class _TrackSummary extends StatelessWidget {
  const _TrackSummary({required this.track, required this.status, required this.isSynced});

  final MediaItem? track;
  final LyricsStatus status;
  final bool isSynced;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final artist = track?.artist ?? 'Unknown Artist';
    final album = track?.album ?? 'Unknown Album';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          TrackCoverArt(track: track, size: 64, style: CoverStyle.rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track?.title ?? 'Nothing playing',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$artist • $album',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (status == LyricsStatus.ready)
            _TypeBadge(
              isSynced: isSynced,
            ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isSynced});

  final bool isSynced;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final color = isSynced ? scheme.primary : scheme.onSurfaceVariant;
    final bg = isSynced ? scheme.primary.withValues(alpha: 0.12) : scheme.onSurfaceVariant.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        isSynced ? 'Synced' : 'Unsynced',
        style: text.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _LyricsBody extends StatelessWidget {
  const _LyricsBody({super.key, required this.controller, required this.isSynced, required this.buildStyle});

  final LyricController controller;
  final bool isSynced;
  final LyricStyle Function(BuildContext context) buildStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isSynced ? scheme.surfaceContainerHigh : scheme.surfaceContainer;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: LyricView(
                controller: controller,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                style: buildStyle(context),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(color: scheme.primary, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text('Fetching lyrics…', style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lyrics_outlined, color: scheme.onSurfaceVariant, size: 48),
            const SizedBox(height: 14),
            Text(
              'No lyrics found',
              style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'We could not find lyrics for this track.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
