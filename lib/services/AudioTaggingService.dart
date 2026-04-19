import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/services/CoverArtStore.dart';

class AudioTaggingService {
  static Future<Tag?> readTag(String path) async {
    try {
      return await AudioTags.read(path);
    } catch (e) {
      debugPrint('Tag read failed for $path: $e');
      return null;
    }
  }

  static Future<TrackCompanion> read(String path) async {
    final fallbackTitle = path.split(Platform.pathSeparator).last;
    final fileModifiedDate = await File(path).lastModified();

    try {
      final tag = await readTag(path);

      if (tag == null) {
        return TrackCompanion.insert(
          path: path,
          title: fallbackTitle,
          lastModified: Value(fileModifiedDate),
          isIndexed: const Value(true),
        );
      }

      String? coverPath;
      if (tag.pictures.isNotEmpty) {
        coverPath = await CoverArtStore.put(tag.pictures.first);
      }

      final title = (tag.title != null && tag.title!.trim().isNotEmpty) ? tag.title! : fallbackTitle;

      return TrackCompanion.insert(
        path: path,
        trackNo: Value(tag.trackNumber),
        year: Value(tag.year),
        albumArtist: Value(tag.albumArtist),
        title: title,
        artist: Value(tag.trackArtist),
        album: Value(tag.album),
        genre: Value(tag.genre),
        coverPath: Value(coverPath),
        duration: Value(tag.duration),
        lastModified: Value(fileModifiedDate),
        isIndexed: const Value(true),
      );
    } catch (e) {
      debugPrint('Tag read failed for $path: $e');
      return TrackCompanion.insert(
        path: path,
        title: fallbackTitle,
        lastModified: Value(fileModifiedDate),
        isIndexed: const Value(true),
      );
    }
  }

  static Future<void> write(TrackData track) async {
    final tag = Tag(
      title: track.title,
      trackArtist: track.artist,
      albumArtist: track.albumArtist,
      album: track.album,
      genre: track.genre,
      year: track.year,
      trackNumber: track.trackNo,
      pictures: [],
    );

    try {
      await AudioTags.write(track.path, tag);
    } catch (e) {
      debugPrint('Tag write failed for ${track.path}: $e');
      rethrow;
    }
  }
}
