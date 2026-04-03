import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/services/AudioPlayerHandlerService.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

enum ButtonState { paused, playing, loading }

enum RepeatState { off, repeatSong, repeatPlaylist }

class ProgressBarState {
  const ProgressBarState({required this.current, required this.buffered, required this.total});

  final Duration current;
  final Duration buffered;
  final Duration total;

  static const zero = ProgressBarState(current: Duration.zero, buffered: Duration.zero, total: Duration.zero);
}

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
  final _musicSrv = getIt<MusicService>();

  final currentTrackNotifier = ValueNotifier<MediaItem?>(null);

  int? get currentIdx => _musicSrv.currEffIdx;
  final queueNotifier = ValueNotifier<List<MediaItem>>([]);
  final progressNotifier = ValueNotifier<ProgressBarState>(ProgressBarState.zero);
  final playButtonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isShuffleEnabledNotifier = ValueNotifier<bool>(false);
  final isFirstTrackNotifier = ValueNotifier<bool>(true);
  final isLastTrackNotifier = ValueNotifier<bool>(true);

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

  void _listenToQueue() {
    _musicSrv.Q.addListener(() {
      final q = _musicSrv.Q.value;
      queueNotifier.value = q;
      _updateSkipButtons();
    });
  }

  void _listenToCurrentTrack() {
    _musicSrv.curr.addListener(() {
      currentTrackNotifier.value = _musicSrv.curr.value;
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final player = _musicSrv.handler.player;
    isFirstTrackNotifier.value = !player.hasPrevious;
    isLastTrackNotifier.value = !player.hasNext;
  }

  void _listenToPlayerState() {
    _musicSrv.playerSS.listen((state) {
      final processing = state.processingState;
      if (processing == ProcessingState.loading || processing == ProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!state.playing) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processing == ProcessingState.completed) {
        _musicSrv.seek(Duration.zero);
        _musicSrv.pause();
        playButtonNotifier.value = ButtonState.paused;
      } else {
        playButtonNotifier.value = ButtonState.playing;
      }
    });
  }

  void _listenToPosition() {
    _musicSrv.posS.listen((position) {
      final old = progressNotifier.value;
      progressNotifier.value = ProgressBarState(current: position, buffered: old.buffered, total: old.total);
    });
  }

  void _listenToBufferedPosition() {
    _musicSrv.bufPosS.listen((buffered) {
      final old = progressNotifier.value;
      progressNotifier.value = ProgressBarState(current: old.current, buffered: buffered, total: old.total);
    });
  }

  void _listenToDuration() {
    _musicSrv.durS.listen((duration) {
      final old = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: old.current,
        buffered: old.buffered,
        total: duration ?? Duration.zero,
      );
    });
  }

  void _listenToShuffleMode() {
    _musicSrv.shuffleModeS.listen((enabled) {
      isShuffleEnabledNotifier.value = enabled;
    });
  }

  void _listenToNavigationState() {
    void refresh() {
      isFirstTrackNotifier.value = !_musicSrv.handler.player.hasPrevious;
      isLastTrackNotifier.value = !_musicSrv.handler.player.hasNext;
    }

    _musicSrv.playerSS.listen((_) => refresh());
    _musicSrv.shuffleModeS.listen((_) => refresh());
    _musicSrv.Q.addListener(refresh);
    _musicSrv.curr.addListener(refresh);

    refresh();
  }

  void play() => _musicSrv.play();

  void pause() => _musicSrv.pause();

  void seek(Duration position) => _musicSrv.seek(position);

  void next() => _musicSrv.next();

  void prev() => _musicSrv.prev();

  void toggleRepeat() {
    repeatButtonNotifier.nextState();
    _musicSrv.setRepeatMode(repeatButtonNotifier.toLoopMode());
  }

  void toggleShuffle() {
    final enabled = !isShuffleEnabledNotifier.value;
    isShuffleEnabledNotifier.value = enabled;
    _musicSrv.setShuffleMode(enabled);
  }

  void setShuffle(bool enabled) {
    isShuffleEnabledNotifier.value = enabled;
    _musicSrv.setShuffleMode(enabled);
  }

  Future<void> stop() async {
    await _musicSrv.stop();
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
