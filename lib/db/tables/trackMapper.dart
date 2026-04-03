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
      extras: {
        'url': 'file://$path',
        "trackNo": trackNo,
        "year": year,
        "albumArtist": albumArtist,
        "path": path,
        "id": id,
      },
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

  TrackData toTrackData() {
    final coverPath = artUri?.toFilePath();
    final id = extras?["id"] ?? -1;
    final path = extras?["path"] as String? ?? '';
    return TrackData(
      id: id,
      title: title,
      artist: artist,
      album: album,
      genre: genre,
      coverPath: coverPath,
      path: path,
      isIndexed: true,
    );
  }
}
