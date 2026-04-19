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
        "duration": duration,
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
      duration: Value(extras?["duration"] as int?),
    );
  }

  TrackData toTrackData() {
    final coverPath = artUri?.toFilePath();
    final id = extras?["id"] as int? ?? int.tryParse(this.id) ?? -1;
    final path = extras?["path"] as String? ?? '';
    final trackNo = extras?["trackNo"] as int?;
    final year = extras?["year"] as int?;
    final albumArtist = extras?["albumArtist"] as String?;
    final duration = extras?["duration"] as int?;
    return TrackData(
      id: id,
      trackNo: trackNo,
      title: title,
      artist: artist,
      path: path,
      albumArtist: albumArtist,
      album: album,
      genre: genre,
      year: year,
      duration: duration,
      coverPath: coverPath,
      isIndexed: true,
    );
  }
}
