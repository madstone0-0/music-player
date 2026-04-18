import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/intents/trackNavigation.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/search.dart';
import 'package:music_player/screens/widgets/artistItem.dart';
import 'package:music_player/screens/widgets/coverArt.dart';
import 'package:music_player/screens/widgets/search.dart';
import 'package:music_player/screens/widgets/trackRow.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';
import 'package:music_player/services/SearchService.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({super.key, required this.query});

  final String query;

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  late final SearchViewModel vm;
  late final MusicService music;
  late final String _tag;

  @override
  void initState() {
    super.initState();
    music = getIt<MusicService>();
    _tag = 'search_vm_${DateTime.now().microsecondsSinceEpoch}';
    vm = Get.put(SearchViewModel(), tag: _tag);
    vm.run(widget.query);
  }

  @override
  void didUpdateWidget(covariant SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      vm.run(widget.query);
    }
  }

  @override
  void dispose() {
    Get.delete<SearchViewModel>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final results = vm.results.value;
      final loading = vm.isLoading.value;
      final error = vm.error.value;

      if (error != null) {
        return Center(
          child: Text(error, style: textTheme.bodyMedium?.copyWith(color: scheme.error)),
        );
      }

      if (loading && results.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (results.isEmpty) {
        return SearchEmptyHint(
          title: 'No results',
          subtitle: 'Try a different search term',
          icon: Icons.search_off_rounded,
        );
      }

      final sectionSpacing = const SizedBox(height: 12);

      return ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          if (loading) ...[const LinearProgressIndicator(minHeight: 2), const SizedBox(height: 12)],

          if (results.tracks.isNotEmpty) ...[
            _SectionHeader(title: 'Tracks'),
            ...List.generate(
              results.tracks.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: TrackRow(
                  track: results.tracks[index].toMediaItem(),
                  onPressed: () => music.playAll(results.tracks, index: index),
                ),
              ),
            ),
            sectionSpacing,
          ],

          if (results.albums.isNotEmpty) ...[
            _SectionHeader(title: 'Albums'),
            ...results.albums.map(_buildAlbumTile),
            sectionSpacing,
          ],

          if (results.artists.isNotEmpty) ...[
            _SectionHeader(title: 'Artists'),
            ...results.artists.map(_buildArtistTile),
          ],
        ],
      );
    });
  }

  Widget _buildAlbumTile(AlbumSearchResult result) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final track = result.album.toMediaItem();
    final albumTitle = track.album ?? 'Unknown Album';
    final albumArtist = track.artist ?? 'Unknown Artist';
    final trackCountLabel = '${result.trackCount} ${result.trackCount == 1 ? 'track' : 'tracks'}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(width: 52, height: 52, child: buildCoverArt(track, 52, scheme: scheme)),
      ),
      title: Text(
        albumTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '$albumArtist · $trackCountLabel',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      onTap: () => TrackNavigation.openAlbum(context: context, album: track.album, artist: track.artist),
    );
  }

  Widget _buildArtistTile(ArtistSearchResult result) {
    return ArtistItem(
      artist: result.artist,
      onTap: () => TrackNavigation.openArtist(context: context, artist: result.artist.name, grouping: result.grouping),
      isGrid: false,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
