import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/daos/playlist.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/db/repo/playlist.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';
import 'package:music_player/services/PlayerStateService.dart';
import 'package:music_player/intents/queueIntent.dart';

class PlaylistTracksViewModel extends GetxController {
  final PlaylistRepository _repo = getIt<PlaylistRepository>();
  final MusicService _mscSrv = getIt<MusicService>();
  final PlayerStateService _plySrv = getIt<PlayerStateService>();
  final QueueActionHandler _queueActions = QueueActionHandler();

  final isLoading = true.obs;
  final playlistName = RxnString();
  final entries = <PlaylistEntryWithTrack>[].obs;

  final currentTrackId = RxnString();
  final currentIndex = RxnInt();

  late final int playlistId;

  StreamSubscription<List<PlaylistEntryWithTrack>>? _entriesSub;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is int) {
      playlistId = args;
    } else if (args is Map && args['playlistId'] is int) {
      playlistId = args['playlistId'] as int;
    } else {
      throw ArgumentError('PlaylistTracks requires a playlistId argument.');
    }

    _bindCurrentTrack();
    _loadPlaylist();
    _bindEntries();
  }

  /// Binds listeners to the current track and queue notifiers to keep track of the currently playing track and its index in the playlist.
  void _bindCurrentTrack() {
    currentTrackId.value = _plySrv.currentTrackNotifier.value?.id;
    currentIndex.value = _plySrv.currentIdx;

    _plySrv.currentTrackNotifier.addListener(_handleCurrentTrackChanged);
    _plySrv.queueNotifier.addListener(_handleQueueChanged);
  }

  /// Handles changes to the current track by updating the current track ID and index based on the playlist entries.
  void _handleCurrentTrackChanged() {
    currentTrackId.value = _plySrv.currentTrackNotifier.value?.id;
    currentIndex.value = _resolveCurrentPlaylistIndex();
  }

  /// Handles changes to the queue by updating the current index based on the playlist entries.
  void _handleQueueChanged() {
    currentIndex.value = _resolveCurrentPlaylistIndex();
  }

  /// Resolves the current playlist index by matching the current track ID with the entries in the playlist. Returns null if no match is found.
  int? _resolveCurrentPlaylistIndex() {
    final id = _plySrv.currentTrackNotifier.value?.id;
    if (id == null) return null;

    final idx = entries.indexWhere((e) => e.track.id.toString() == id);
    return idx == -1 ? null : idx;
  }

  /// Loads the playlist details, specifically the playlist name, based on the provided playlist ID. If the playlist is not found, it defaults to 'Playlist'.
  Future<void> _loadPlaylist() async {
    final playlist = await _repo.getPlaylistById(playlistId);
    playlistName.value = playlist?.name ?? 'Playlist';
  }

  /// Binds the playlist entries by subscribing to changes in the playlist tracks. Updates the entries list and current index whenever the playlist tracks change.
  void _bindEntries() {
    _entriesSub?.cancel();
    isLoading.value = true;

    _entriesSub = _repo.watchPlaylistTracks(playlistId).listen((items) {
      entries.assignAll(items);
      currentIndex.value = _resolveCurrentPlaylistIndex();
      isLoading.value = false;
    });
  }

  /// Retrieves the list of tracks from the playlist entries.
  List<TrackData> get _tracks => entries.map((e) => e.track).toList();

  /// Plays all tracks in the playlist sequentially. If the playlist is empty, it does nothing.
  Future<void> playAll() async {
    if (_tracks.isEmpty) return;
    await _mscSrv.playAll(_tracks);
  }

  /// Shuffles and plays all tracks in the playlist. If the playlist is empty, it does nothing.
  Future<void> shuffleAll() async {
    if (_tracks.isEmpty) return;
    await _mscSrv.playAll(_tracks, shuffle: true);
  }

  /// Plays tracks starting from the specified index in the playlist. If the playlist is empty or the index is out of bounds, it does nothing.
  Future<void> playFrom(int index) async {
    if (_tracks.isEmpty) return;
    await _mscSrv.playAll(_tracks, index: index);
  }

  /// Plays the next track in the queue based on the specified index in the playlist. If the index is out of bounds, it does nothing.
  Future<void> playNext(int index) async {
    if (index < 0 || index >= entries.length) return;
    await _queueActions.playNext(QueueIntent.track(entries[index].track));
  }

  /// Adds the specified track from the playlist to the end of the queue. If the index is out of bounds, it does nothing.
  Future<void> addToQueue(int index) async {
    if (index < 0 || index >= entries.length) return;
    await _queueActions.addToQueue(QueueIntent.track(entries[index].track));
  }

  /// Adds all tracks in the playlist to the end of the queue. If the playlist is empty, it does nothing.
  Future<void> addAllToQueue() async {
    await _mscSrv.addAllToQueue(_tracks);
  }

  /// Removes the track at the specified index from the playlist. If the index is out of bounds, it does nothing.
  Future<void> removeEntryAt(int index) async {
    if (index < 0 || index >= entries.length) return;
    await _repo.removeEntry(entries[index].entry.id);
  }

  @override
  void onClose() {
    _entriesSub?.cancel();
    _plySrv.currentTrackNotifier.removeListener(_handleCurrentTrackChanged);
    _plySrv.queueNotifier.removeListener(_handleQueueChanged);
    super.onClose();
  }
}
