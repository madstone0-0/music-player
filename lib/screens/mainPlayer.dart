import 'dart:io';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/common/color.dart';
import 'package:music_player/common/nav.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/mainPlayer.dart';
import 'package:music_player/screens/playlistModal.dart';
import 'package:music_player/screens/widgets/coverArt.dart';
import 'package:music_player/screens/widgets/popupMenu.dart';
import 'package:music_player/screens/widgets/trackCoverArt.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/PageManagerService.dart';
import "./widgets/controlButtons.dart";
import '../models/playlistModal.dart';

class MainPlayer extends StatefulWidget {
  const MainPlayer({super.key});

  @override
  State<MainPlayer> createState() => MainPlayerState();
}

class MainPlayerState extends State<MainPlayer> {
  final vm = Get.put(MainPlayerViewModel(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final playerState = getIt<PlayerStateService>();
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
            onPressed: () => Get.back(),
            tooltip: 'Close',
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 28, color: scheme.onSurface),
          ),
          title: Text(
            'Now Playing',
            style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          actions: [
            PopupMenu(
              scheme: scheme,
              items: [
                PopupMenuItemData(value: 0, icon: Icons.playlist_add_rounded, label: 'Add to Playlist'),
                PopupMenuItemData(value: 1, icon: Icons.info_outline, label: "Details"),
                PopupMenuItemData(value: 3, icon: Icons.album_rounded, label: "View Album"),
                PopupMenuItemData(value: 4, icon: Icons.person_rounded, label: "View Artist"),
                PopupMenuItemData(value: 2, icon: Icons.lyrics_outlined, label: "Lyrics"),
              ],
              onSelected: (v) {
                switch (v) {
                  case 0:
                    final current = playerState.currentTrackNotifier.value;
                    if (current != null) {
                      PlaylistModal.open(context, PlaylistAddIntent.track(current.toTrackData()));
                    }
                    break;
                  case 1:
                    break;
                  case 2:
                    break;
                  case 3:
                    break;
                  case 4:
                    break;
                }
              },
            ),
          ],
        ),

        body: ValueListenableBuilder<MediaItem?>(
          valueListenable: playerState.currentTrackNotifier,
          builder: (context, track, _) {
            return _PlayerBody(track: track, page: playerState, vm: vm);
          },
        ),
      ),
    );
  }
}

class _PlayerBody extends StatelessWidget {
  const _PlayerBody({required this.track, required this.page, required this.vm});

  final MainPlayerViewModel vm;
  final MediaItem? track;
  final PlayerStateService page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final title = track?.title ?? "Unknown Title";
    final artistAlbum = [track?.artist ?? "Unknown Artist", track?.album ?? "Unknown Album"].join(' • ');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),

          _ArtworkWithSeek(track: track, page: page, vm: vm, screenSize: size),

          const SizedBox(height: 20),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.titleLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),

          Text(
            artistAlbum,
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

          PrimaryControls(page: page),

          const SizedBox(height: 16),

          SecondaryControls(page: page),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ArtworkWithSeek extends StatelessWidget {
  const _ArtworkWithSeek({required this.track, required this.page, required this.vm, required this.screenSize});

  final MainPlayerViewModel vm;
  final MediaItem? track;
  final PlayerStateService page;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Clamp artwork by both width and height so it stays proportionate in
    // landscape orientation, where the available height is very limited.
    final double size = (screenSize.width * 0.70).clamp(0.0, min(screenSize.height * 0.42, 300.0));

    return Hero(
      tag: 'currentArtwork',
      child: TrackCoverArt(
        track: track,
        size: size,
        style: CoverStyle.rounded,
        coverArtOverride: _artwork(scheme, size),
      ),
    );
  }

  Widget _artwork(ColorScheme scheme, double size) {
    return Obx(() {
      final art = vm.coverArt;

      if (art != null) {
        return Image.memory(art.bytes, width: size, height: size, fit: BoxFit.cover);
      }

      if (track!.artUri != null) {
        return Image.file(
          File(track!.artUri!.toFilePath()),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => coverArtPlaceholder(scheme, size),
        );
      }

      return coverArtPlaceholder(scheme, size);
    });
  }
}

class _LinearSeekBar extends StatelessWidget {
  const _LinearSeekBar({required this.page});

  final PlayerStateService page;

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
            inactiveTrackColor: scheme.primary.withValues(alpha: 0.2),
            thumbColor: scheme.primary,
            overlayColor: scheme.primary.withValues(alpha: 0.12),
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

class _Timestamps extends StatelessWidget {
  const _Timestamps({required this.page});

  final PlayerStateService page;

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
