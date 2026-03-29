import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/services/AudioPlayerHandlerService.dart';
import 'package:music_player/services/LocatorService.dart';

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

class PageManagerService {
  final _handler = getIt<AudioPlayerHandlerService>();

  final currentTrackNotifier = ValueNotifier<MediaItem?>(null);
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
  }

  // ── Listeners ─────────────────────────────────────────────────────────────────

  void _listenToQueue() {
    _handler.Q.addListener(() {
      final q = _handler.Q.value;
      queueNotifier.value = q;
      _updateSkipButtons();
    });
  }

  void _listenToCurrentTrack() {
    _handler.curr.addListener(() {
      currentTrackNotifier.value = _handler.curr.value;
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final q = _handler.Q.value;
    final track = _handler.curr.value;
    if (q.length < 2 || track == null) {
      isFirstTrackNotifier.value = true;
      isLastTrackNotifier.value = true;
    } else {
      isFirstTrackNotifier.value = q.first.id == track.id;
      isLastTrackNotifier.value = q.last.id == track.id;
    }
  }

  void _listenToPlayerState() {
    _handler.playerSS.listen((state) {
      final processing = state.processingState;
      if (processing == ProcessingState.loading || processing == ProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!state.playing) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processing == ProcessingState.completed) {
        // Auto-restart at end of queue.
        _handler.seek(Duration.zero);
        _handler.pause();
        playButtonNotifier.value = ButtonState.paused;
      } else {
        playButtonNotifier.value = ButtonState.playing;
      }
    });
  }

  void _listenToPosition() {
    _handler.posS.listen((position) {
      final old = progressNotifier.value;
      progressNotifier.value = ProgressBarState(current: position, buffered: old.buffered, total: old.total);
    });
  }

  void _listenToBufferedPosition() {
    _handler.bufPosS.listen((buffered) {
      final old = progressNotifier.value;
      progressNotifier.value = ProgressBarState(current: old.current, buffered: buffered, total: old.total);
    });
  }

  void _listenToDuration() {
    _handler.durS.listen((duration) {
      final old = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: old.current,
        buffered: old.buffered,
        total: duration ?? Duration.zero,
      );
    });
  }

  void play() => _handler.play();

  void pause() => _handler.pause();

  void seek(Duration position) => _handler.seek(position);

  void next() => _handler.skipToNext();

  void previous() => _handler.skipToPrevious();

  void skipTo(int index) => _handler.skipToQueueItem(index);

  void toggleRepeat() {
    repeatButtonNotifier.nextState();
    _handler.setRepeatMode(repeatButtonNotifier.toLoopMode());
  }

  void toggleShuffle() {
    final enabled = !isShuffleEnabledNotifier.value;
    isShuffleEnabledNotifier.value = enabled;
    _handler.setShuffleMode(enabled);
  }

  void setShuffle(bool enabled) {
    isShuffleEnabledNotifier.value = enabled;
    _handler.setShuffleMode(enabled);
  }

  Future<void> stop() async {
    await _handler.stop();
    await _handler.seek(Duration.zero);
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
    _handler.dispose();
  }
}
