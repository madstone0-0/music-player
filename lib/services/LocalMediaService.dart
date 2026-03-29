import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

const Set<String> AUDIO_EXTENSIONS = {'.mp3', '.m4a', '.aac', '.wav', '.flac'};

String extOf(String path) {
  final name = path.split(Platform.pathSeparator).last.toLowerCase();
  final dot = name.lastIndexOf('.');
  if (dot == -1) return '';
  return name.substring(dot);
}

List<LocalMediaFile> _scanDirectoryTask(Map<String, dynamic> args) {
  final String baseDirectory = args['baseDirectory'];
  final bool recursive = args['recursive'];
  final Set<String> supportedExtensions = args['supportedExtensions'];

  final dir = Directory(baseDirectory);
  if (!dir.existsSync()) {
    return <LocalMediaFile>[];
  }

  final results = <LocalMediaFile>[];

  // Using listSync avoids the massive overhead of async stream events
  final entities = dir.listSync(recursive: recursive, followLinks: false);

  for (final entity in entities) {
    if (entity is! File) continue;

    final path = entity.path;
    final ext = extOf(path);

    if (!supportedExtensions.contains(ext)) continue;

    try {
      // statSync grabs file info instantly from the OS
      final stat = entity.statSync();

      results.add(
        LocalMediaFile(
          path: path,
          name: LocalMediaService.fileNameOf(path),
          sizeBytes: stat.size,
          modifiedAt: stat.modified,
        ),
      );
    } catch (_) {
      // Skip unreadable files
    }
  }

  // Sort in the background so the UI doesn't freeze
  results.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return results;
}

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

  Future<List<LocalMediaFile>> scanAudioFiles() async {
    return await compute(_scanDirectoryTask, {
      'baseDirectory': baseDirectory,
      'recursive': recursive,
      'supportedExtensions': supportedExtensions,
    });
  }

  Future<bool> canAccessBaseDirectory() async {
    return Directory(baseDirectory).exists();
  }

  // Changed from private (_fileNameOf) to public so the top-level isolate task can use it
  static String fileNameOf(String path) {
    return path.split(Platform.pathSeparator).last;
  }
}
