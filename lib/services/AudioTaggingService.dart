import 'dart:io';

import "package:audiotags/audiotags.dart";
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

class AudioTaggingService {
  static Future<TrackCompanion> read(String path, {DateTime? fileModifiedDate}) async {
    final fallbackTitle = path.split(Platform.pathSeparator).last;

    try {
      var tag = await AudioTags.read(path);
      if (tag == null) {
        return TrackCompanion.insert(path: path, title: fallbackTitle);
      }

      String? coverPath;
      if (tag.pictures.isNotEmpty) {
        coverPath = await coverPathOf(path);
        final coverFile = File(coverPath);

        if (!coverFile.existsSync()) {
          // Lower the quality of the image to reduce file size
          await coverFile.writeAsBytes(await compressImage(tag.pictures.first, quality: 50));
        }
      }

      final title = (tag.title != null && tag.title!.trim().isNotEmpty) ? tag.title! : fallbackTitle;

      return TrackCompanion.insert(
        path: path,
        trackNo: Value(tag.trackNumber),
        title: title,
        artist: Value(tag.trackArtist),
        album: Value(tag.album),
        genre: Value(tag.genre),
        coverPath: Value(coverPath),
        lastModified: Value(fileModifiedDate),
      );
    } catch (e) {
      debugPrint('Tag read failed for $path: $e');
      return TrackCompanion.insert(path: path, title: fallbackTitle);
    }
  }

  static void write(TrackData track) async {
    var tag = Tag(title: track.title, trackArtist: track.artist, album: track.album, genre: track.genre, pictures: []);

    await AudioTags.write(track.path, tag);
  }
}
