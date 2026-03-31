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
      extras: {'url': 'file://$path', "trackNo": trackNo, "year": year, "albumArtist": albumArtist, "path": path},
    );
  }
}

extension MediaItemMapper on MediaItem {
  TrackCompanion toCompanion() {
    final coverPath = artUri?.toFilePath();
    return TrackCompanion(
      path: Value(extras?["path"] as String? ?? ''),
      title: Value(title),
      trackNo: Value(extras?["trackNo"] as int?),
      year: Value(extras?["year"] as int?),
      albumArtist: Value(extras?["albumArtist"] as String?),
      artist: Value(artist),
      album: Value(album),
      genre: Value(genre),
      coverPath: Value(coverPath),
    );
  }
}
