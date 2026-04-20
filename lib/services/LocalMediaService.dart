/// This service scans the local file system for media files (primarily audio) and provides metadata about them.
/// It uses the `path_provider` package to find common directories and the `compute` function to perform the
/// scanning in a background isolate, ensuring the UI remains responsive.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Set of supported audio file extensions
const Set<String> AUDIO_EXTENSIONS = {'.mp3', '.m4a', '.aac', '.wav', '.flac'};

String extOf(String path) {
  final name = path.split(Platform.pathSeparator).last.toLowerCase();
  final dot = name.lastIndexOf('.');
  if (dot == -1) return '';
  return name.substring(dot);
}

/// Scans the specified directory for media files matching the supported extensions.
Future<List<LocalMediaFile>> _scanDirectoryTask(Map<String, dynamic> args) async {
  final String baseDirectory = args['baseDirectory'];
  final bool recursive = args['recursive'];
  final Set<String> supportedExtensions = args['supportedExtensions'];

  final dir = Directory(baseDirectory);
  if (!dir.existsSync()) return <LocalMediaFile>[];

  final results = <LocalMediaFile>[];

  await for (final entity in dir.list(recursive: recursive, followLinks: false)) {
    if (entity is! File) continue;

    final path = entity.path;
    final ext = p.extension(path).toLowerCase();

    if (!supportedExtensions.contains(ext)) continue;

    try {
      final stat = await entity.stat();

      results.add(LocalMediaFile(path: path, name: p.basename(path), sizeBytes: stat.size, modifiedAt: stat.modified));
    } catch (_) {
      // Skip unreadable files
    }
  }

  return results;
}

/// Represents a media file found on the local file system, containing its path, name, size, and modification date.
class LocalMediaFile {
  final String path;
  final String name;
  final int sizeBytes;
  final DateTime modifiedAt;

  const LocalMediaFile({required this.path, required this.name, required this.sizeBytes, required this.modifiedAt});

  bool get isAudio => AUDIO_EXTENSIONS.contains(extOf(path));
}

class LocalMediaService {
  LocalMediaService._({required this.baseDirectory, required this.recursive, required this.supportedExtensions});

  final String baseDirectory;
  final bool recursive;
  final Set<String> supportedExtensions;

  /// Factory method to create an instance of LocalMediaService. It resolves the base directory for scanning, which can be provided or automatically determined.
  static Future<LocalMediaService> create({
    String? musicDirectory,
    bool recursive = true,
    Set<String> supportedExtensions = AUDIO_EXTENSIONS,
  }) async {
    final resolvedDirectory = musicDirectory ?? await _findMusicDir();

    return LocalMediaService._(
      baseDirectory: resolvedDirectory,
      recursive: recursive,
      supportedExtensions: supportedExtensions,
    );
  }

  /// Attempts to find a suitable music directory on the device. It checks common locations and falls back to application-specific directories if necessary.
  static Future<String> _findMusicDir() async {
    final musicDir = Directory('/storage/emulated/0/Music');
    if (await musicDir.exists()) {
      return musicDir.path;
    }

    final external = await getExternalStorageDirectory();
    if (external != null) {
      return Directory('${external.path}/Music').path;
    }

    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/Music').path;
  }

  /// Scans the base directory for media files matching the supported extensions.
  /// This operation is performed in a background isolate to avoid blocking the UI.
  Future<List<LocalMediaFile>> scanAudioFiles() async {
    return await compute(_scanDirectoryTask, {
      'baseDirectory': baseDirectory,
      'recursive': recursive,
      'supportedExtensions': supportedExtensions,
    });
  }

  /// Checks if the base directory is accessible and exists. This can be used to verify permissions and availability before attempting to scan.
  Future<bool> canAccessBaseDirectory() async {
    return Directory(baseDirectory).exists();
  }

  /// Utility method to extract the file name from a given path. It splits the path by the platform's path separator and returns the last segment.
  static String fileNameOf(String path) {
    return path.split(Platform.pathSeparator).last;
  }
}
