import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/screens/albumTracks.dart';
import 'package:music_player/screens/artistAlbums.dart';

class TrackNavigation {
  static bool openAlbum({
    required BuildContext context,
    required String? album,
    String? artist,
  }) {
    if (album == null || album.isEmpty) return false;
    FocusScope.of(context).unfocus();

    Get.to(
      () => const AlbumTracks(),
      arguments: {'album': album, 'artist': artist},
      transition: Transition.rightToLeftWithFade,
    );
    return true;
  }

  static bool openArtist({
    required BuildContext context,
    required String? artist,
    ArtistGrouping grouping = ArtistGrouping.artist,
  }) {
    if (artist == null || artist.isEmpty) return false;
    FocusScope.of(context).unfocus();

    Get.to(
      () => ArtistAlbums(artistName: artist, grouping: grouping),
      transition: Transition.rightToLeftWithFade,
    );
    return true;
  }

  static (String? name, ArtistGrouping grouping) resolveArtistTarget(MediaItem track) {
    final albumArtist = track.extras?['albumArtist'] as String?;
    if (albumArtist != null && albumArtist.isNotEmpty) {
      return (albumArtist, ArtistGrouping.albumArtist);
    }

    return (track.artist, ArtistGrouping.artist);
  }
}
