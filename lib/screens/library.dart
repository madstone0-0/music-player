import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/nav.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/models/albums.dart';
import 'package:music_player/models/artists.dart';
import 'package:music_player/models/tracks.dart';
import 'package:music_player/screens/albums.dart';
import 'package:music_player/screens/artists.dart';
import 'package:music_player/screens/tracks.dart';
import 'package:music_player/screens/widgets/search.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = <({String label, IconData icon})>[
    (label: 'Tracks', icon: Icons.music_note_outlined),
    (label: 'Albums', icon: Icons.album_outlined),
    (label: 'Artists', icon: Icons.people_outline),
    (label: 'Album Artists', icon: Icons.person_outline),
    // (label: 'Playlists',  icon: Icons.queue_music_outlined),
    // (label: 'Genres',     icon: Icons.category_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Pre-register the Tracks ViewModel synchronously so its DB query starts
    // before the first build frame — the tab screen will find the existing
    // instance instead of re-creating it.
    Get.put(TracksViewModel());

    // Pre-register the non-default tab ViewModels after the first frame has
    // been rendered.  This gives the Tracks query a head-start while ensuring
    // Albums / Artists / Album Artists data is already loading long before the
    // user swipes to those tabs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.put(AlbumsViewModel());
      Get.put(ArtistsViewModel(grouping: ArtistGrouping.artist), tag: ArtistGrouping.artist.name);
      Get.put(ArtistsViewModel(grouping: ArtistGrouping.albumArtist), tag: ArtistGrouping.albumArtist.name);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            forceElevated: innerBoxIsScrolled,

            title: Text(
              "Library",
              style: textTheme.titleLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton.filledTonal(
                  onPressed: _openSearch,
                  tooltip: 'Search',
                  style: IconButton.styleFrom(
                    backgroundColor: scheme.surfaceContainerHighest,
                    foregroundColor: scheme.onSurfaceVariant,
                  ),
                  icon: const Icon(Icons.search_rounded, size: 20),
                ),
              ),
            ],

            bottom: _tabs.length > 1 ? _StyledTabBar(controller: _tabController, tabs: _tabs) : null,
          ),
        ],

        body: TabBarView(
          controller: _tabController,
          children: const [
            Tracks(),
            Albums(),
            Artists(),
            Artists(grouping: ArtistGrouping.albumArtist),
            // Genres(),
            // Playlists(),
          ],
        ),
      ),
    );
  }

  void _openSearch() {
    Get.to(
      () => SearchScreen(
        hint: 'Search songs, albums, artists…',
        hintTitle: 'Search your library',
        hintSubtitle: 'Find songs, albums and artists',
        resultsBuilder: (context, query) => _SearchResults(query: query),
      ),
      transition: Transition.fadeIn,
    );
  }
}

class _StyledTabBar extends StatelessWidget implements PreferredSizeWidget {
  const _StyledTabBar({required this.controller, required this.tabs});

  final TabController controller;
  final List<({String label, IconData icon})> tabs;

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TabBar(
      controller: controller,
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      dividerColor: Colors.transparent,

      indicator: BoxDecoration(borderRadius: BorderRadius.circular(20), color: scheme.secondaryContainer),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: const EdgeInsets.symmetric(vertical: 6),

      labelColor: scheme.onSecondaryContainer,
      unselectedLabelColor: scheme.onSurfaceVariant,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,

      padding: const EdgeInsets.symmetric(horizontal: 12),

      tabs: tabs
          .map(
            (t) => Tab(
              height: kTextTabBarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(t.icon, size: 16), const SizedBox(width: 6), Text(t.label)],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Results for "$query"',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
