import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/tracks.dart';
import 'package:music_player/intents/trackNavigation.dart';
import 'package:music_player/intents/queueIntent.dart';
import 'package:music_player/screens/playlistModal.dart';
import 'package:music_player/screens/widgets/editTags.dart';
import 'package:music_player/screens/widgets/popupMenu.dart';
import 'package:music_player/screens/widgets/sort.dart';
import 'package:music_player/screens/widgets/trackRow.dart';
import 'package:music_player/screens/widgets/azList.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';
import '../models/playlistModal.dart';

class Tracks extends StatefulWidget {
  const Tracks({super.key});

  @override
  State<Tracks> createState() => _TracksState();
}

class _TracksState extends State<Tracks> with AutomaticKeepAliveClientMixin {
  final player = getIt<MusicService>();
  final queueActions = QueueActionHandler();
  late final TracksViewModel vm;

  @override
  bool get wantKeepAlive => true;

  Future<void> _editTags(TrackData track) async {
    final edited = await EditTags.open(context, track);
    if (!mounted || edited == null) return;
    _showInfo('Tags updated');
  }

  void _handleMenuSelection(int v, TrackData track) async {
    final intent = QueueIntent.track(track);

    switch (v) {
      case 0:
        await queueActions.playNext(intent);
        break;
      case 1:
        await queueActions.addToQueue(intent);
        break;
      case 2:
        PlaylistModal.open(context, PlaylistAddIntent.track(track));
        break;
      case 3:
        _openAlbum(track);
        break;
      case 4:
        _openArtist(track);
        break;
      case 5:
        _editTags(track);
        break;
    }
  }

  void _openAlbum(TrackData track) {
    final ok = TrackNavigation.openAlbum(context: context, album: track.album, artist: track.artist);

    if (!ok) _showInfo('Album details not available for this track.');
  }

  void _openArtist(TrackData track) {
    final target = TrackNavigation.resolveArtistTarget(track.toMediaItem());
    final ok = TrackNavigation.openArtist(context: context, artist: target.$1, grouping: target.$2);

    if (!ok) _showInfo('Artist details not available for this track.');
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    vm = Get.isRegistered<TracksViewModel>() ? Get.find<TracksViewModel>() : Get.put(TracksViewModel());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SortSection<TrackSortMode>(
            options: const [
              SortChipOption(label: 'Title', asc: TrackSortMode.titleAsc, desc: TrackSortMode.titleDesc),
              SortChipOption(label: 'Artist', asc: TrackSortMode.artistAsc, desc: TrackSortMode.artistDesc),
              SortChipOption(label: 'Album', asc: TrackSortMode.albumAsc, desc: TrackSortMode.albumDesc),
            ],
            currentMode: vm.sortMode,
            onToggle: vm.toggleSort,
          ),

          Expanded(
            child: Obx(
              () => AZList<AZTrack>(
                items: vm.azItms.value,
                emptyMessage: 'No tracks found, try scanning',
                itemBuilder: (context, item, index) => Padding(
                  padding: AZList.itemPadding,
                  child: TrackRow(
                    track: item.track.toMediaItem(),
                    onPressed: () => player.playAll(vm.all.value, index: index),
                    // On long press show a popup menu with options to add to queue, add to playlist, view album, view artist
                    onLongPress: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => PopupMenu(
                        longPress: true,
                        scheme: scheme,
                        items: [
                          PopupMenuItemData(value: 0, icon: Icons.queue_music_rounded, label: 'Play Next'),
                          PopupMenuItemData(value: 1, icon: Icons.playlist_add_rounded, label: 'Add to Queue'),
                          PopupMenuItemData(value: 2, icon: Icons.playlist_add_rounded, label: 'Add to Playlist'),
                          PopupMenuItemData(value: 3, icon: Icons.album_rounded, label: 'View Album'),
                          PopupMenuItemData(value: 4, icon: Icons.person_rounded, label: 'View Artist'),
                          PopupMenuItemData(value: 5, icon: Icons.edit_rounded, label: 'Edit Tags'),
                        ],
                        onSelected: (v) => _handleMenuSelection(v, item.track),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
