import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/mainTab.dart';
import 'package:music_player/models/playlistModal.dart';
import 'package:music_player/intents/queueIntent.dart';
import 'package:music_player/screens/library.dart';
import 'package:music_player/screens/mainTab.dart';
import 'package:music_player/screens/widgets/playlistModal.dart';
import 'package:music_player/screens/widgets/popupMenu.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';
import 'package:music_player/services/PlayerStateService.dart';
import 'package:music_player/screens/widgets/trackCoverArt.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:music_player/intents/trackNavigation.dart';

class PlayerQueue extends StatefulWidget {
  const PlayerQueue({super.key});

  @override
  State<PlayerQueue> createState() => _PlayerQueueState();
}

class _PlayerQueueState extends State<PlayerQueue> {
  late final AutoScrollController _scrollController;
  final queueActions = QueueActionHandler();

  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> _scrollToCurrentTrack(PlayerStateService page, int queueLength) async {
    final idx = page.currentIdx;
    if (idx == null || idx < 0 || idx >= queueLength) return;

    await _scrollController.scrollToIndex(
      idx,
      preferPosition: AutoScrollPosition.middle,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = getIt<PlayerStateService>();
    final player = getIt<MusicService>();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ValueListenableBuilder<List<MediaItem>>(
      valueListenable: playerState.queueNotifier,
      builder: (context, Q, _) {
        if (Q.isEmpty) {
          return const SizedBox.shrink();
        }

        // Scroll to current song only once when we first open the queue
        if (!_didInitialScroll) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            _didInitialScroll = true;
            await _scrollToCurrentTrack(playerState, Q.length);
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Text(
                    'Queue',
                    style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Text('(${Q.length})', style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  // Clear queue button to the right
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      player.clearQueue();
                      // Close the queue view after clearing
                      Get.back();
                    },
                    icon: const Icon(Icons.clear_all_rounded),
                    color: scheme.onSurfaceVariant,
                    tooltip: 'Clear Queue',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                scrollController: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: Q.length,
                onReorder: (oldIdx, newIdx) {
                  if (newIdx > oldIdx) newIdx--;
                  player.moveQueueItem(oldIdx, newIdx);
                },
                itemBuilder: (context, idx) {
                  final track = Q[idx];
                  final isCurrent =
                      playerState.currentTrackNotifier.value?.id == track.id && playerState.currentIdx == idx;

                  return AutoScrollTag(
                    key: ValueKey("tag_$idx"),
                    controller: _scrollController,
                    index: idx,
                    child: ListTile(
                      onTap: () => player.skipTo(idx),
                      onLongPress: () => showModalBottomSheet(
                        context: context,
                        builder: (context) => PopupMenu(
                          scheme: scheme,
                          longPress: true,
                          items: [
                            PopupMenuItemData(value: 0, icon: Icons.queue_music_rounded, label: 'Play Next'),
                            PopupMenuItemData(
                              value: 1,
                              icon: Icons.remove_circle_outline_rounded,
                              label: 'Remove from Queue',
                            ),
                            PopupMenuItemData(value: 2, icon: Icons.playlist_add_rounded, label: 'Add to Playlist'),
                            PopupMenuItemData(value: 3, icon: Icons.album_rounded, label: 'View Album'),
                            PopupMenuItemData(value: 4, icon: Icons.person_rounded, label: 'View Artist'),
                          ],
                          onSelected: (int selectedIdx) async {
                            switch (selectedIdx) {
                              case 0:
                                await queueActions.playNext(QueueIntent.track(Q[idx].toTrackData()));
                                break;
                              case 1:
                                player.removeFromQueue(idx);
                                break;
                              case 2:
                                PlaylistModal.open(
                                  context,
                                  PlaylistAddIntent.track(Q[idx].toTrackData()),
                                );
                                break;
                              case 3:
                                _openAlbum(context, Q[idx]);
                                break;
                              case 4:
                                _openArtist(context, Q[idx]);
                                break;
                            }
                          },
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: isCurrent ? scheme.primaryContainer.withValues(alpha: 0.3) : null,
                      leading: isCurrent
                          ? Icon(Icons.music_note_rounded, color: scheme.primary, size: 24)
                          : Text('${idx + 1}', style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                      title: Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyLarge?.copyWith(
                          color: isCurrent ? scheme.primary : scheme.onSurface,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        track.artist ?? 'Unknown Artist',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      trailing: ReorderableDragStartListener(
                        index: idx,
                        child: Icon(Icons.drag_handle_rounded, color: scheme.onSurfaceVariant),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _openAlbum(BuildContext context, MediaItem track) {
    final ok = TrackNavigation.openAlbum(
      context: context,
      album: track.album,
      artist: track.artist,
    );

    if (!ok) _showInfo(context, 'Album details not available for this track.');
  }

  void _openArtist(BuildContext context, MediaItem track) {
    final target = TrackNavigation.resolveArtistTarget(track);
    final ok = TrackNavigation.openArtist(
      context: context,
      artist: target.$1,
      grouping: target.$2,
    );

    if (!ok) _showInfo(context, 'Artist details not available for this track.');
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
