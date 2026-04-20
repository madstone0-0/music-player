/// This service manages the state of the audio player, including the current track, queue, playback state, and UI-related states like repeat and shuffle modes.
/// It listens to changes in the MusicService and updates its notifiers accordingly, allowing the UI to react to
/// changes in the player's state.
library;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

/// Represents the state of the play/pause button, which can be paused, playing, or loading.
enum ButtonState { paused, playing, loading }

/// Represents the repeat mode of the player, which can be off, repeat the current song, or repeat the entire playlist.
enum RepeatState { off, repeatSong, repeatPlaylist }

/// Represents the state of the progress bar, including the current position, buffered position, and total duration of the track.
class ProgressBarState {
  const ProgressBarState({required this.current, required this.buffered, required this.total});

  final Duration current;
  final Duration buffered;
  final Duration total;

  static const zero = ProgressBarState(current: Duration.zero, buffered: Duration.zero, total: Duration.zero);
}

/// A custom notifier for the repeat button, which cycles through the repeat states and can convert to the LoopMode used by just_audio.
class RepeatButtonNotifier extends ValueNotifier<RepeatState> {
  RepeatButtonNotifier() : super(RepeatState.off);

  void nextState() {
    value = RepeatState.values[(value.index + 1) % RepeatState.values.length];
  }

  LoopMode toLoopMode() => switch (value) {
    RepeatState.off => LoopMode.off,
    RepeatState.repeatSong => LoopMode.one,
    RepeatState.repeatPlaylist => LoopMode.all,
  };
}

class PlayerStateService {
  final _mscSrv = getIt<MusicService>();

  final currentTrackNotifier = ValueNotifier<MediaItem?>(null);

  int? get currentIdx => _mscSrv.currEffIdx;
  final queueNotifier = ValueNotifier<List<MediaItem>>([]);
  final progressNotifier = ValueNotifier<ProgressBarState>(ProgressBarState.zero);
  final playButtonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isShuffleEnabledNotifier = ValueNotifier<bool>(false);
  final isFirstTrackNotifier = ValueNotifier<bool>(true);
  final isLastTrackNotifier = ValueNotifier<bool>(true);

  /// Initializes the service by setting up listeners to the MusicService's state changes,
  /// allowing it to update its notifiers accordingly.
  void init() {
    _listenToQueue();
    _listenToCurrentTrack();
    _listenToPlayerState();
    _listenToPosition();
    _listenToBufferedPosition();
    _listenToDuration();
    _listenToNavigationState();
    _listenToShuffleMode();
  }

  /// Listens to changes in the music queue and updates the queue notifier and skip button states accordingly.
  void _listenToQueue() {
    _mscSrv.Q.addListener(() {
      final q = _mscSrv.Q.value;
      queueNotifier.value = q;
      _updateSkipButtons();
    });
  }

  /// Listens to changes in the current track and updates the current track notifier and skip button states accordingly.
  void _listenToCurrentTrack() {
    _mscSrv.curr.addListener(() {
      currentTrackNotifier.value = _mscSrv.curr.value;
      _updateSkipButtons();
    });
  }

  /// Updates the state of the skip buttons (previous and next) based on whether there are tracks available to skip to in the current queue.
  void _updateSkipButtons() {
    final player = _mscSrv.handler.player;
    isFirstTrackNotifier.value = !player.hasPrevious;
    isLastTrackNotifier.value = !player.hasNext;
  }

  /// Listens to changes in the player's state (playing, paused, loading, completed) and updates the play button notifier accordingly.
  void _listenToPlayerState() {
    _mscSrv.playerSS.listen((state) {
      final processing = state.processingState;
      if (processing == ProcessingState.loading || processing == ProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!state.playing) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processing == ProcessingState.completed) {
        _mscSrv.seek(Duration.zero);
        _mscSrv.pause();
        playButtonNotifier.value = ButtonState.paused;
      } else {
        playButtonNotifier.value = ButtonState.playing;
      }
    });
  }

  /// Listens to changes in the current playback position and updates the progress notifier accordingly.
  void _listenToPosition() {
    _mscSrv.posS.listen((position) {
      final old = progressNotifier.value;
      progressNotifier.value = ProgressBarState(current: position, buffered: old.buffered, total: old.total);
    });
  }

  /// Listens to changes in the buffered position and updates the progress notifier accordingly.
  void _listenToBufferedPosition() {
    _mscSrv.bufPosS.listen((buffered) {
      final old = progressNotifier.value;
      progressNotifier.value = ProgressBarState(current: old.current, buffered: buffered, total: old.total);
    });
  }

  /// Listens to changes in the total duration of the current track and updates the progress notifier accordingly.
  void _listenToDuration() {
    _mscSrv.durS.listen((duration) {
      final old = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: old.current,
        buffered: old.buffered,
        total: duration ?? Duration.zero,
      );
    });
  }

  /// Listens to changes in the shuffle mode and updates the shuffle mode notifier accordingly.
  void _listenToShuffleMode() {
    _mscSrv.shuffleModeS.listen((enabled) {
      isShuffleEnabledNotifier.value = enabled;
    });
  }

  /// Listens to changes in the player's navigation state (whether there are previous or next tracks available)
  /// and updates the corresponding notifiers accordingly.
  void _listenToNavigationState() {
    void refresh() {
      isFirstTrackNotifier.value = !_mscSrv.handler.player.hasPrevious;
      isLastTrackNotifier.value = !_mscSrv.handler.player.hasNext;
    }

    _mscSrv.playerSS.listen((_) => refresh());
    _mscSrv.shuffleModeS.listen((_) => refresh());
    _mscSrv.Q.addListener(refresh);
    _mscSrv.curr.addListener(refresh);

    refresh();
  }

  void play() => _mscSrv.play();

  void pause() => _mscSrv.pause();

  void seek(Duration position) => _mscSrv.seek(position);

  void next() => _mscSrv.next();

  void prev() => _mscSrv.prev();

  void toggleRepeat() {
    repeatButtonNotifier.nextState();
    _mscSrv.setRepeatMode(repeatButtonNotifier.toLoopMode());
  }

  void toggleShuffle() {
    final enabled = !isShuffleEnabledNotifier.value;
    isShuffleEnabledNotifier.value = enabled;
    _mscSrv.setShuffleMode(enabled);
  }

  void setShuffle(bool enabled) {
    isShuffleEnabledNotifier.value = enabled;
    _mscSrv.setShuffleMode(enabled);
  }

  Future<void> stop() async {
    await _mscSrv.stop();
    currentTrackNotifier.value = null;
  }

  void dispose() {
    currentTrackNotifier.dispose();
    queueNotifier.dispose();
    progressNotifier.dispose();
    playButtonNotifier.dispose();
    repeatButtonNotifier.dispose();
    isShuffleEnabledNotifier.dispose();
    isFirstTrackNotifier.dispose();
    isLastTrackNotifier.dispose();
  }
}
