import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/common/color.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/PageManagerService.dart';
import "./widgets/controlButtons.dart";

class MainPlayer extends StatelessWidget {
  const MainPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final page = getIt<PageManagerService>();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Dismissible(
      key: const Key('playScreen'),
      direction: DismissDirection.down,
      onDismissed: (_) => Get.back(),
      background: const ColoredBox(color: Colors.transparent),
      child: Scaffold(
        backgroundColor: scheme.surface,

        appBar: AppBar(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: IconButton(
            onPressed: Get.back,
            tooltip: 'Close',
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 28, color: scheme.onSurface),
          ),
          title: Text(
            'Now Playing',
            style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          actions: [MoreMenu(scheme: scheme)],
        ),

        body: ValueListenableBuilder<MediaItem?>(
          valueListenable: page.currentTrackNotifier,
          builder: (context, track, _) {
            if (track == null) return const SizedBox.shrink();
            return _PlayerBody(track: track, page: page);
          },
        ),
      ),
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────────

class _PlayerBody extends StatelessWidget {
  const _PlayerBody({required this.track, required this.page});

  final MediaItem track;
  final PageManagerService page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // ── Artwork + circular seek bar ────────────────────────────────
            _ArtworkWithSeek(track: track, page: page, width: width),

            const SizedBox(height: 20),

            // ── Track info ────────────────────────────────────────────────
            Text(
              track.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.titleLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              [if (track.artist != null) track.artist!, if (track.album != null) track.album!].join(' • '),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),

            const SizedBox(height: 20),

            _LinearSeekBar(page: page),

            const SizedBox(height: 8),
            _Timestamps(page: page),

            const SizedBox(height: 24),

            PrimaryContols(page: page),

            const Spacer(),

            SecondaryControls(page: page),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Artwork ──────────────────────────────────────────────────────────────────

class _ArtworkWithSeek extends StatelessWidget {
  const _ArtworkWithSeek({required this.track, required this.page, required this.width});

  final MediaItem track;
  final PageManagerService page;
  final double width;

  @override
  Widget build(BuildContext context) {
    final artSize = width * 0.78;

    return Hero(
      tag: 'currentArtwork',
      child: SizedBox.square(
        dimension: artSize,
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          clipBehavior: Clip.antiAlias,
          child: _artwork(artSize),
        ),
      ),
    );
  }

  Widget _artwork(double size) {
    if (track.artUri != null) {
      return Image.file(
        File(track.artUri!.toFilePath()),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(size),
      );
    }
    return _placeholder(size);
  }

  Widget _placeholder(double size) => Image.asset('assets/img/cover.jpg', width: size, height: size, fit: BoxFit.cover);
}

// ─── Linear seek bar ──────────────────────────────────────────────────────────

class _LinearSeekBar extends StatelessWidget {
  const _LinearSeekBar({required this.page});

  final PageManagerService page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: page.progressNotifier,
      builder: (context, state, _) {
        final total = state.total.inMilliseconds.toDouble();
        final current = state.current.inMilliseconds.toDouble().clamp(0.0, total == 0 ? 1.0 : total);

        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            activeTrackColor: scheme.primary,
            inactiveTrackColor: scheme.primary.withOpacity(0.2),
            thumbColor: scheme.primary,
            overlayColor: scheme.primary.withOpacity(0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            min: 0,
            max: total == 0 ? 1.0 : total,
            value: current,
            onChanged: (v) => page.seek(Duration(milliseconds: v.round())),
            onChangeEnd: (v) => page.seek(Duration(milliseconds: v.round())),
          ),
        );
      },
    );
  }
}

// ─── Timestamps ───────────────────────────────────────────────────────────────

class _Timestamps extends StatelessWidget {
  const _Timestamps({required this.page});

  final PageManagerService page;

  static final _re = RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$');

  String _fmt(Duration d) => _re.firstMatch('$d')?.group(1) ?? '$d';

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: page.progressNotifier,
      builder: (context, state, _) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_fmt(state.current), style: style),
          Text(_fmt(state.total), style: style),
        ],
      ),
    );
  }
}
