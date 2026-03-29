import 'package:drift/drift.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/db/db.dart';

extension TrackMapper on TrackData {
  MediaItem toMediaItem() {
    return MediaItem(
      id: id.toString(),
      title: title,
      artist: artist,
      album: album,
      genre: genre,
      artUri: coverPath != null && coverPath!.isNotEmpty ? Uri.file(coverPath!) : null,
      extras: {'url': 'file://$path', "trackNo": trackNo},
    );
  }
}

extension MediaItemMapper on MediaItem {
  TrackCompanion toCompanion() {
    final coverPath = artUri?.toFilePath();
    return TrackCompanion(
      title: Value(title),
      trackNo: Value(extras?["trackNo"] as int?),
      artist: Value(artist),
      album: Value(album),
      genre: Value(genre),
      coverPath: Value(coverPath),
    );
  }
}
