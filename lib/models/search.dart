import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/models/artists.dart';
import 'package:get/get.dart';
import 'package:music_player/models/search.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/SearchService.dart';

class AlbumSearchResult {
  const AlbumSearchResult({required this.album, required this.trackCount});

  final TrackData album;
  final int? trackCount;
}

class ArtistSearchResult {
  const ArtistSearchResult({required this.artist, required this.grouping});

  final ArtistData artist;
  final ArtistGrouping grouping;
}

class SearchResults {
  const SearchResults({required this.tracks, required this.albums, required this.artists});

  final List<TrackData> tracks;
  final List<AlbumSearchResult> albums;
  final List<ArtistSearchResult> artists;

  static const empty = SearchResults(tracks: [], albums: [], artists: []);

  bool get isEmpty => tracks.isEmpty && albums.isEmpty && artists.isEmpty;
}

class SearchViewModel extends GetxController {

  final SearchService searchService = getIt<SearchService>();

  final results = SearchResults.empty.obs;
  final isLoading = false.obs;
  final error = RxnString();

  int _requestId = 0;

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
      final next = await searchService.search(trimmed);
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
