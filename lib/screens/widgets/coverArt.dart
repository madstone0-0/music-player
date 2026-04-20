import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/common/color.dart';

Widget coverArtPlaceholder(ColorScheme scheme, double size) {
  return Container(
    width: size,
    height: size,
    color: scheme.surfaceContainerHighest,
    child: Icon(Icons.music_note_rounded, color: scheme.onSurfaceVariant, size: 24),
  );
}

Widget buildCoverArt(
  MediaItem? track,
  double size, {
  ColorScheme scheme = const ColorScheme.dark(),
}) {
  if (track == null) {
    return coverArtPlaceholder(scheme, size);
  }

  final uri = track.artUri;

  if (uri == null) {
    return coverArtPlaceholder(scheme, size);
  }

  if (uri.scheme.startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: uri.toString(),
      fit: BoxFit.cover,
      width: size,
      height: size,
      placeholder: (_, __) => coverArtPlaceholder(scheme, size),
      errorWidget: (_, __, ___) => coverArtPlaceholder(scheme, size),
    );
  }

  if (uri.scheme == 'file') {
    try {
      return Image.file(
        File(uri.toFilePath()),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => coverArtPlaceholder(scheme, size),
      );
    } catch (e) {
      return coverArtPlaceholder(scheme, size);
    }
  }

  return coverArtPlaceholder(scheme, size);
}
