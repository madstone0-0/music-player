/// This service handles searching for tracks, albums, and artists in the music player database.
/// It provides a unified search method that takes a query string and returns results across multiple categories.
library;

import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/models/artists.dart';
import 'package:music_player/models/search.dart';

class SearchService {
  SearchService({required this.repo});

  final TrackRepository repo;

  /// Searches for tracks, albums, and artists matching the given query.
  /// It performs the searches concurrently and returns a unified SearchResults object containing the results.
  Future<SearchResults> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return SearchResults.empty;

    final tracksFuture = repo.searchTracks(trimmed, limit: 40);
    final albumsFuture = repo.searchAlbums(trimmed, limit: 25);
    final artistsFuture = _searchArtists(trimmed, limit: 25);

    final results = await Future.wait([tracksFuture, albumsFuture, artistsFuture]);

    final tracks = results[0] as List<TrackData>;
    final albums = _dedupeAlbums(results[1] as List<AlbumSearchRow>);
    final artists = results[2] as List<ArtistSearchResult>;

    return SearchResults(tracks: tracks, albums: albums, artists: artists);
  }

  /// Deduplicates album search results by normalizing album and artist names.
  /// It creates a unique key for each album based on the album name and artist, and keeps only one entry per unique key.
  /// The resulting list is sorted alphabetically by album name.
  List<AlbumSearchResult> _dedupeAlbums(List<AlbumSearchRow> rows) {
    final deduped = <String, AlbumSearchResult>{};

    for (final row in rows) {
      final albumName = row.album.album ?? '';
      final albumKey =
          '${albumName.trim().toLowerCase()}|${(row.album.albumArtist ?? row.album.artist ?? '').trim().toLowerCase()}';

      if (albumName.trim().isEmpty) continue;

      deduped.putIfAbsent(albumKey, () => AlbumSearchResult(album: row.album, trackCount: row.trackCount));
    }

    final list = deduped.values.toList()
      ..sort((a, b) => (a.album.album ?? '').toLowerCase().compareTo((b.album.album ?? '').toLowerCase()));

    return list;
  }

  /// Searches for artists matching the given query across both artist and album artist groupings.
  Future<List<ArtistSearchResult>> _searchArtists(String query, {int limit = 20}) async {
    final artists = await repo.searchArtists(query, grouping: ArtistGrouping.artist, limit: limit);
    final albumArtists = await repo.searchArtists(query, grouping: ArtistGrouping.albumArtist, limit: limit);

    final merged = <String, ArtistSearchResult>{};

    void addRows(List<Map<String, dynamic>> rows, ArtistGrouping grouping) {
      for (final row in rows) {
        final data = ArtistData.fromMap(row, grouping);
        final key = data.name.trim().toLowerCase();
        if (key.isEmpty) continue;

        final existing = merged[key];
        if (existing == null) {
          merged[key] = ArtistSearchResult(artist: data, grouping: grouping);
          continue;
        }

        final trackCount = existing.artist.trackCount + data.trackCount;
        merged[key] = ArtistSearchResult(
          artist: ArtistData(
            name: existing.artist.name,
            trackCount: trackCount,
            coverPath: existing.artist.coverPath ?? data.coverPath,
          ),
          grouping: existing.grouping == ArtistGrouping.albumArtist ? existing.grouping : grouping,
        );
      }
    }

    addRows(artists, ArtistGrouping.artist);
    addRows(albumArtists, ArtistGrouping.albumArtist);

    final values = merged.values.toList()
      ..sort((a, b) => a.artist.name.toLowerCase().compareTo(b.artist.name.toLowerCase()));

    if (values.length > limit) {
      return values.sublist(0, limit);
    }
    return values;
  }
}
