import 'package:flutter_lyric/core/lyric_model.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_lyric/utils/lyric_lrc_to_qrc.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/services/LyricsService.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';
import 'package:music_player/services/PlayerStateService.dart';

enum LyricsStatus { loading, ready, empty }

class LyricsViewModel extends GetxController {
  LyricsViewModel({required MediaItem initialTrack}) {
    track.value = initialTrack;
  }

  final _lyricsService = getIt<LyricsService>();
  final _playerState = getIt<PlayerStateService>();

  final LyricController con = LyricController();

  final Rxn<MediaItem> track = Rxn<MediaItem>();
  final Rxn<Lyrics> lyrics = Rxn<Lyrics>();
  final Rx<LyricsStatus> status = LyricsStatus.loading.obs;

  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    con.setOnTapLineCallback(_seekTo);
    _playerState.currentTrackNotifier.addListener(_handleTrackChange);
    _playerState.progressNotifier.addListener(_handleProgress);
    _loadLyricsFor(track.value);
  }

  @override
  void onClose() {
    con.cancelOnTapLineCallback();
    _playerState.currentTrackNotifier.removeListener(_handleTrackChange);
    _playerState.progressNotifier.removeListener(_handleProgress);
    con.dispose();
    super.onClose();
  }

  Future<void> refresh() => _loadLyricsFor(track.value);

  void _handleTrackChange() {
    final next = _playerState.currentTrackNotifier.value;
    if (next == null || track.value?.id == next.id) return;
    track.value = next;
    _loadLyricsFor(next);
  }

  void _handleProgress() {
    if (!(lyrics.value?.isSynced ?? false)) return;
    con.setProgress(_playerState.progressNotifier.value.current);
  }

  Future<void> _loadLyricsFor(MediaItem? target) async {
    if (target == null) {
      status.value = LyricsStatus.empty;
      lyrics.value = null;
      con.lyricNotifier.value = null;
      return;
    }

    final id = ++_requestId;
    status.value = LyricsStatus.loading;
    lyrics.value = null;
    con.lyricNotifier.value = null;

    final res = await _lyricsService.getLyrics(target.toTrackData());
    if (!isClosed && id == _requestId) {
      if (res == null) {
        status.value = LyricsStatus.empty;
        return;
      }

      lyrics.value = res;
      if (res.isSynced) {
        // Try qrc conversion
        final dur = target.extras?["duration"] as int?;
        final qrc = LrcToQrcUtil.convert(res.content, totalDuration: dur != null ? Duration(seconds: dur) : null);
        if (qrc.trim().isNotEmpty) {
          con.loadLyric(qrc);
        } else {
          con.loadLyric(res.content);
        }
        con.setProgress(_playerState.progressNotifier.value.current);
      } else {
        con.loadLyricModel(_buildPlainModel(res.content));
        con.setProgress(Duration.zero);
      }
      status.value = LyricsStatus.ready;
    }
  }

  LyricModel _buildPlainModel(String content) {
    final lines = content.split(RegExp(r'\r?\n')).map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    final safeLines = lines.isEmpty ? [content.trim()] : lines;

    return LyricModel(
      lines: [
        for (final entry in safeLines.asMap().entries)
          LyricLine(
            start: Duration(milliseconds: entry.key * 1400),
            text: entry.value,
          ),
      ],
    );
  }

  void _seekTo(Duration position) {
    getIt<MusicService>().seek(position);
  }
}
