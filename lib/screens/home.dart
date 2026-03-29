import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/color.dart';
import 'package:music_player/models/home.dart';
import 'package:music_player/models/splash.dart';
import 'package:music_player/screens/widgets/playlistCell.dart';
import 'package:music_player/screens/widgets/trackRow.dart';
import 'package:music_player/screens/widgets/viewAllSection.dart';

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

    return Scaffold(
      // Let the body extend behind the app bar for the blur effect.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColor.bg.withOpacity(0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.find<SplashViewModel>().openDrawer(),
          icon: Icon(Icons.menu, size: 22, color: AppColor.primaryText),
        ),
        title: _SearchBar(controller: vm.txtSearch.value),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: kToolbarHeight + 24)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                'Good ${_greeting()},',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColor.secondaryText),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Text(
                'What are you listening to?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColor.primaryText,
                  fontWeight: FontWeight.w700,
                ),
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
          //   child: Divider(color: AppColor.primaryText.withOpacity(0.07), indent: 20, endIndent: 20, height: 32),
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      hintText: 'Search songs, albums…',
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(AppColor.primaryText.withOpacity(0.07)),
      overlayColor: WidgetStatePropertyAll(AppColor.primaryText.withOpacity(0.04)),
      side: WidgetStatePropertyAll(BorderSide(color: AppColor.primaryText.withOpacity(0.08))),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
      textStyle: WidgetStatePropertyAll(TextStyle(color: AppColor.primaryText, fontSize: 14)),
      hintStyle: WidgetStatePropertyAll(TextStyle(color: AppColor.primaryText28, fontSize: 14)),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(Icons.search_rounded, size: 18, color: AppColor.primaryText28),
      ),
    );
  }
}
