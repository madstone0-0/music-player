import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/playlist.dart';

class PlaylistService {
  PlaylistService({required this.repo});

  final PlaylistRepository repo;

  // Enumerate all playlist for UI
  Future<List<PlaylistData>> all() async {
    return await repo.getAllPlaylists();
  }

  Future<PlaylistData?> one(int id) async {
    return await repo.getPlaylistById(id);
  }

  // Add track to playlist
  Future<void> addTrack(int playlistId, int trackId) async {
    await repo.addTrackToPlaylist(playlistId, trackId);
  }
}
