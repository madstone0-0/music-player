import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/models/artists.dart';
import 'package:get/get.dart';
import 'package:music_player/models/search.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/SearchService.dart';

/// Represents a search result for an album, including the album data and the number of tracks it contains.
class AlbumSearchResult {
  const AlbumSearchResult({required this.album, required this.trackCount});

  final TrackData album;
  final int? trackCount;
}

/// Represents a search result for an artist, including the artist data and the grouping it belongs to.
class ArtistSearchResult {
  const ArtistSearchResult({required this.artist, required this.grouping});

  final ArtistData artist;
  final ArtistGrouping grouping;
}

/// Represents the combined search results for tracks, albums, and artists.
class SearchResults {
  const SearchResults({required this.tracks, required this.albums, required this.artists});

  final List<TrackData> tracks;
  final List<AlbumSearchResult> albums;
  final List<ArtistSearchResult> artists;

  static const empty = SearchResults(tracks: [], albums: [], artists: []);

  bool get isEmpty => tracks.isEmpty && albums.isEmpty && artists.isEmpty;
}

class SearchViewModel extends GetxController {

  final SearchService _srhSrv = getIt<SearchService>();

  final results = SearchResults.empty.obs;
  final isLoading = false.obs;
  final error = RxnString();

  int _requestId = 0;

  /// Executes a search query and updates the search results, loading state, and error state accordingly.
  Future<void> run(String query) async {
    final trimmed = query.trim();
    final requestId = ++_requestId;

    if (trimmed.isEmpty) {
      error.value = null;
      isLoading.value = false;
      results.value = SearchResults.empty;
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final next = await _srhSrv.search(trimmed);
      if (_requestId == requestId) {
        results.value = next;
      }
    } catch (e) {
      if (_requestId == requestId) {
        error.value = 'Search failed. Please try again.';
      }
    } finally {
      if (_requestId == requestId) {
        isLoading.value = false;
      }
    }
  }
}
