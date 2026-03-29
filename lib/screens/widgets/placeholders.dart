import 'package:flutter/material.dart';

Widget coverArtPlaceholder(ColorScheme scheme, double size) {
  return Container(
    width: size,
    height: size,
    color: scheme.surfaceContainerHighest,
    child: Icon(Icons.music_note_rounded, color: scheme.onSurfaceVariant, size: 24),
  );
}
