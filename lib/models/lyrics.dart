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

/// Represents the fetching status of lyrics for a track.
enum LyricsStatus { loading, ready, empty }

class LyricsViewModel extends GetxController {
  LyricsViewModel({required MediaItem initialTrack}) {
    track.value = initialTrack;
  }

  final _lyrSrv = getIt<LyricsService>();
  final _plySrv = getIt<PlayerStateService>();

  final LyricController lyrCon = LyricController();

  final Rxn<MediaItem> track = Rxn<MediaItem>();
  final Rxn<Lyrics> lyrics = Rxn<Lyrics>();
  final Rx<LyricsStatus> status = LyricsStatus.loading.obs;

  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    lyrCon.setOnTapLineCallback(_seekTo);
    _plySrv.currentTrackNotifier.addListener(_handleTrackChange);
    _plySrv.progressNotifier.addListener(_handleProgress);
    _loadLyricsFor(track.value);
  }

  @override
  void onClose() {
    lyrCon.cancelOnTapLineCallback();
    _plySrv.currentTrackNotifier.removeListener(_handleTrackChange);
    _plySrv.progressNotifier.removeListener(_handleProgress);
    lyrCon.dispose();
    super.onClose();
  }

  /// Manually refreshes the lyrics for the current track.
  Future<void> refresh() => _loadLyricsFor(track.value);

  void _handleTrackChange() {
    final next = _plySrv.currentTrackNotifier.value;
    if (next == null || track.value?.id == next.id) return;
    track.value = next;
    _loadLyricsFor(next);
  }

  void _handleProgress() {
    if (!(lyrics.value?.isSynced ?? false)) return;
    lyrCon.setProgress(_plySrv.progressNotifier.value.current);
  }

  /// Loads lyrics for the given [target] track. If [target] is null, clears the current lyrics.
  Future<void> _loadLyricsFor(MediaItem? target) async {
    if (target == null) {
      status.value = LyricsStatus.empty;
      lyrics.value = null;
      lyrCon.lyricNotifier.value = null;
      return;
    }

    // Increment request ID to ensure only the latest request updates the state
    final id = ++_requestId;
    status.value = LyricsStatus.loading;
    lyrics.value = null;
    lyrCon.lyricNotifier.value = null;

    // Fetch lyrics asynchronously from lyrics service
    final res = await _lyrSrv.getLyrics(target.toTrackData());
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
          lyrCon.loadLyric(qrc);
        } else {
          lyrCon.loadLyric(res.content);
        }
        lyrCon.setProgress(_plySrv.progressNotifier.value.current);
      } else {
        lyrCon.loadLyricModel(_makeModel(res.content));
        lyrCon.setProgress(Duration.zero);
      }
      status.value = LyricsStatus.ready;
    }
  }

  /// Builds a simple [LyricModel] from plain text content, treating each non-empty line as a lyric line with a fixed interval.
  LyricModel _makeModel(String content) {
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
    _plySrv.seek(position);
  }
}
