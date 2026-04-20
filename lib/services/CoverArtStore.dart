/// A simple cover art store that saves compressed images to the app's documents directory.
library;

import 'package:audiotags/audiotags.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:music_player/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CoverArtStore {
  /// Saves the cover art image and returns the file path. It uses a hash of the image bytes to avoid duplicates.
  static Future<Directory> _coverDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'cover_art'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Generates a SHA-1 hash of the image bytes to create a unique identifier for the cover art.
  static String _hashBytes(Uint8List bytes) {
    return sha1.convert(bytes).toString();
  }

  /// Compresses the image and saves it to the cover art directory, returning the file path.
  /// If the image already exists, it returns the existing path.
  static Future<String> put(Picture pic) async {
    final dir = await _coverDir();
    final hash = _hashBytes(pic.bytes);
    final path = p.join(dir.path, '$hash.jpg');
    final file = File(path);

    if (!await file.exists()) {
      final compressed = await compressImage(pic, quality: 50);
      await file.writeAsBytes(compressed, flush: true);
    }

    return path;
  }
}
