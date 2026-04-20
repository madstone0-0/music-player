import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player/models/artists.dart';
import 'package:music_player/screens/widgets/gridItem.dart';

class ArtistItem extends StatelessWidget {
  const ArtistItem({super.key, required this.artist, this.onTap, this.isGrid = false, this.onLongPress});

  final ArtistData artist;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final trackText = '${artist.trackCount} ${artist.trackCount == 1 ? 'track' : 'tracks'}';

    if (isGrid) {
      return GridItem(
        onTap: onTap,
        onLongPress: onLongPress,
        image: _Avatar(coverPath: artist.coverPath, name: artist.name, scheme: scheme, radius: 48),
        title: artist.name,
        subtitle: trackText,
      );
    }

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: _Avatar(coverPath: artist.coverPath, name: artist.name, scheme: scheme, radius: 24),
      title: Text(artist.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(trackText, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.coverPath, required this.name, required this.scheme, required this.radius});

  final String? coverPath;
  final String name;
  final ColorScheme scheme;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (coverPath != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(coverPath!)),
        backgroundColor: scheme.surfaceContainerHighest,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.secondaryContainer,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.5
        ),
      ),
    );
  }
}
