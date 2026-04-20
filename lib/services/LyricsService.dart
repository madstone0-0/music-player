/// This service handles fetching lyrics for tracks, both from local storage and from an external API.
library;

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/services/ApiService.dart';

/// Represents the lyrics of a track, including whether they are synced (contain timestamps) or not.
class Lyrics {
  final String content;
  late final bool isSynced;

  Lyrics({required this.content}) {
    isSynced = LyricsService.areLyricsSynced(content);
  }
}

class LyricsService {
  final ApiService api;

  LyricsService({required this.api});

  /// Fetch lyrics from the API using track information
  Future<Lyrics?> fetchLyricsAPI(TrackData track) async {
    try {
      final res = await api.getLyrics(
        trackName: track.title,
        artistName: track.artist ?? "",
        albumName: track.album ?? "",
        duration: (track.duration ?? 0).toDouble(),
      );
      if (res.syncedLyrics != null && res.syncedLyrics!.trim().isNotEmpty) {
        return Lyrics(content: res.syncedLyrics!);
      } else if (res.plainLyrics != null && res.plainLyrics!.trim().isNotEmpty) {
        return Lyrics(content: res.plainLyrics!);
      }
    } catch (e) {
      debugPrint("Error fetching lyrics from API: $e");
      return null;
    }
    return null;
  }

  /// Fetch lyrics from local storage. It looks for a .lrc file with the same name as the track.
  Future<String?> fetchLyricsLocal(TrackData track) async {
    // Local lyrics should be stored at the same path as the track with .lrc extension
    final lyricsPath = track.path.replaceAll(RegExp(r'\.\w+$'), '.lrc');
    // Check if the file exists and read it
    final file = File(lyricsPath);
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.trim().isNotEmpty) {
        return content;
      }
      return null;
    }

    return null;
  }

  /// Get lyrics for a track, first trying local storage and then falling back to the API if not found locally.
  Future<Lyrics?> getLyrics(TrackData track) async {
    // First try local lyrics, if not found then fetch from API
    final localLyrics = await fetchLyricsLocal(track);
    if (localLyrics != null) {
      return Lyrics(content: localLyrics);
    }

    final apiLyrics = await fetchLyricsAPI(track);
    if (apiLyrics != null) {
      return apiLyrics;
    }

    return null;
  }

  /// Determines if the lyrics are synced by checking for the presence of timestamps in the lyrics content.
  static bool areLyricsSynced(String lyrics) {
    // If the lyrics contain timestamps, we consider them synced
    final timestampRegex = RegExp(r'\[\d{1,2}:\d{2}(?:\.\d{1,3})?\]');
    return timestampRegex.hasMatch(lyrics);
  }
}
