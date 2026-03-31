import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/nav.dart';
import 'package:music_player/models/home.dart';
import 'package:music_player/screens/widgets/search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final vm = Get.put(HomeViewModel());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              "Home",
              style: textTheme.titleLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            Expanded(child: _SearchBarLauncher(onTap: _openSearch)),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: kToolbarHeight + 24)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text('Good ${_greeting()},', style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurface)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Text(
                'What are you listening to?',
                style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          // SliverToBoxAdapter(
          //   child: ViewAllSection(title: 'Playlists', onPressed: () {}),
          // ),
          // SliverToBoxAdapter(
          //   child: SizedBox(
          //     height: 168,
          //     child: Obx(
          //       () => ListView.builder(
          //         padding: const EdgeInsets.symmetric(horizontal: 16),
          //         scrollDirection: Axis.horizontal,
          //         itemCount: vm.playListArr.length,
          //         itemBuilder: (context, index) {
          //           return PlaylistCell(mObj: vm.playListArr[index]);
          //         },
          //       ),
          //     ),
          //   ),
          // ),

          // SliverToBoxAdapter(
          //   child: Divider(indent: 20, endIndent: 20, height: 32),
          // ),
          //
          // SliverToBoxAdapter(
          //   child: ViewAllSection(title: 'Recently Played', onPressed: () {}),
          // ),
          // Obx(
          //   () => SliverList.builder(
          //     itemCount: vm.recentlyPlayedArr.length,
          //     itemBuilder: (context, index) {
          //       final track = vm.recentlyPlayedArr[index];
          //       return TrackRow(track: track, onPressed: () {}, onPressedPlay: () {});
          //     },
          //   ),
          // ),
          //
          // const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _SearchBarLauncher extends StatelessWidget {
  const _SearchBarLauncher({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SearchBar(
        enabled: false,
        hintText: 'Search songs, albums…',
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.07)),
        overlayColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.04)),
        side: WidgetStatePropertyAll(BorderSide(color: scheme.onSurface.withValues(alpha: 0.08))),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
        textStyle: WidgetStatePropertyAll(TextStyle(color: scheme.onSurface, fontSize: 14)),
        hintStyle: WidgetStatePropertyAll(TextStyle(color: scheme.onSurface.withValues(alpha: 0.28), fontSize: 14)),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(Icons.search_rounded, size: 18, color: scheme.onSurface.withValues(alpha: 0.28)),
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        'Results for "$query"',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
