import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/color.dart';
import 'package:music_player/models/splash.dart';
import 'package:music_player/screens/albums.dart';
import 'package:music_player/screens/artists.dart';
import 'package:music_player/screens/tracks.dart';

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
    (label: 'Artists',    icon: Icons.person_outline),
    // (label: 'Playlists',  icon: Icons.queue_music_outlined),
    // (label: 'Genres',     icon: Icons.category_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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

            // M3 IconButton.filledTonal gives the search icon a proper
            // container rather than a raw icon floating in the app bar.
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
            // Genres(),
            // Playlists(),
          ],
        ),
      ),
    );
  }

  void _openSearch() {
    showSearch(context: context, delegate: _TrackSearchDelegate());
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
      // M3: secondary tab bar style — label indicator, no underline divider.
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      dividerColor: Colors.transparent,

      // Indicator: pill shape in primaryContainer, M3's recommended style.
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

class _TrackSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search tracks…';

  @override
  ThemeData appBarTheme(BuildContext context) {
    // Inherit the app theme so the search bar matches.
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty) IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear_rounded)),
  ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(onPressed: () => close(context, ''), icon: const Icon(Icons.arrow_back_rounded));

  @override
  Widget buildResults(BuildContext context) => _SearchResults(query: query);

  @override
  Widget buildSuggestions(BuildContext context) => query.isEmpty ? const SizedBox() : _SearchResults(query: query);
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    // Wire to your TrackRepository / ViewModel when ready.
    // Placeholder keeps the structure correct in the meantime.
    return Center(
      child: Text(
        'Results for "$query"',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
