import 'package:audiotags/audiotags.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';

Future<String> coverPathOf(String path) async {
  final cacheDir = await getApplicationCacheDirectory();
  final coverPath = "${cacheDir.path}/${path.split("/").last}_cover.jpg";
  return coverPath;
}

Future<Uint8List> compressImage(Picture picture, {int quality = 50}) async {
  try {
    // flutter_image_compress works directly with Uint8List
    final Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
      picture.bytes,
      quality: quality,
      minHeight: 500,
      minWidth: 500,
      format: CompressFormat.jpeg, // Forces standard format
    );

    return compressedBytes;
  } catch (e) {
    // If compression fails (e.g., unsupported format), return original bytes
    return picture.bytes;
  }
}
