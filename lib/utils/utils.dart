import 'package:audiotags/audiotags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';

/// Get the cover image path for a given audio file path.
/// The cover image will be stored in the application's cache directory with a name derived from the audio file name.
Future<String> coverPathOf(String path) async {
  final cacheDir = await getApplicationCacheDirectory();
  final coverPath = "${cacheDir.path}/${path.split("/").last}_cover.jpg";
  return coverPath;
}

/// Extract the cover image from an audio file and save it to the specified cover path.
Future<Uint8List> compressImage(Picture picture, {int quality = 50}) async {
  try {
    final Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
      picture.bytes,
      quality: quality,
      minHeight: 500,
      minWidth: 500,
      format: CompressFormat.jpeg,
    );

    return compressedBytes;
  } catch (e) {
    return picture.bytes;
  }
}

/// Show a SnackBar with the given message in the provided BuildContext.
void showInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
