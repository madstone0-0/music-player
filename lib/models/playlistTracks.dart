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
import 'package:music_player/services/PageManagerService.dart';

class PlaylistTracksViewModel extends GetxController {
  final PlaylistRepository _repo = getIt<PlaylistRepository>();
  final MusicService _player = getIt<MusicService>();
  final PlayerStateService _playerState = getIt<PlayerStateService>();

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

  void _bindCurrentTrack() {
    currentTrackId.value = _playerState.currentTrackNotifier.value?.id;
    currentIndex.value = _playerState.currentIdx;

    _playerState.currentTrackNotifier.addListener(_handleCurrentTrackChanged);
    _playerState.queueNotifier.addListener(_handleQueueChanged);
  }

  void _handleCurrentTrackChanged() {
    currentTrackId.value = _playerState.currentTrackNotifier.value?.id;
    currentIndex.value = _resolveCurrentPlaylistIndex();
  }

  void _handleQueueChanged() {
    currentIndex.value = _resolveCurrentPlaylistIndex();
  }

  int? _resolveCurrentPlaylistIndex() {
    final id = _playerState.currentTrackNotifier.value?.id;
    if (id == null) return null;

    final idx = entries.indexWhere((e) => e.track.id.toString() == id);
    return idx == -1 ? null : idx;
  }

  Future<void> _loadPlaylist() async {
    final playlist = await _repo.getPlaylistById(playlistId);
    playlistName.value = playlist?.name ?? 'Playlist';
  }

  void _bindEntries() {
    _entriesSub?.cancel();
    isLoading.value = true;

    _entriesSub = _repo.watchPlaylistTracks(playlistId).listen((items) {
      entries.assignAll(items);
      currentIndex.value = _resolveCurrentPlaylistIndex();
      isLoading.value = false;
    });
  }

  MediaItem toMediaItem(TrackData track) => track.toMediaItem();

  List<TrackData> get _tracks => entries.map((e) => e.track).toList();

  Future<void> playAll() async {
    if (_tracks.isEmpty) return;
    await _player.playAll(_tracks);
  }

  Future<void> shuffleAll() async {
    if (_tracks.isEmpty) return;
    await _player.playAll(_tracks, shuffle: true);
  }

  Future<void> playFrom(int index) async {
    if (_tracks.isEmpty) return;
    await _player.playAll(_tracks, index: index);
  }

  Future<void> playNext(int index) async {
    if (index < 0 || index >= entries.length) return;
    await _player.playNext(entries[index].track);
  }

  Future<void> addToQueue(int index) async {
    if (index < 0 || index >= entries.length) return;
    await _player.addToQueue(entries[index].track);
  }

  Future<void> addAllToQueue() async {
    for (final item in entries) {
      await _player.addToQueue(item.track);
    }
  }

  Future<void> removeEntryAt(int index) async {
    if (index < 0 || index >= entries.length) return;
    await _repo.removeEntry(entries[index].entry.id);
  }

  @override
  void onClose() {
    _entriesSub?.cancel();
    _playerState.currentTrackNotifier.removeListener(_handleCurrentTrackChanged);
    _playerState.queueNotifier.removeListener(_handleQueueChanged);
    super.onClose();
  }
}
