import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/common/nav.dart';
import 'package:music_player/screens/home.dart';
import 'package:music_player/screens/scanMedia.dart';
import 'package:music_player/screens/library.dart';
import 'package:music_player/screens/widgets/miniPlayer.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/PageManagerService.dart';

class MainTab extends StatefulWidget {
  const MainTab({super.key});

  @override
  State<MainTab> createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [Home(), Library(), ScanMedia()];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final page = getIt<PageManagerService>();

    return Scaffold(
      backgroundColor: scheme.surface,

      body: Stack(
        children: [
          // Inject extra bottom padding into MediaQuery so every scrollable
          // widget inside the tabs automatically leaves room for the mini-player.
          ValueListenableBuilder<MediaItem?>(
            valueListenable: page.currentTrackNotifier,
            builder: (context, track, child) {
              final extra = track != null ? kMiniPlayerHeight : 0.0;
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  padding: mq.padding.copyWith(bottom: mq.padding.bottom + extra),
                ),
                child: child!,
              );
            },
            child: IndexedStack(index: _selectedIndex, children: _screens),
          ),

          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_search_outlined),
            selectedIcon: Icon(Icons.manage_search_rounded),
            label: 'Scan',
          ),
        ],
      ),
    );
  }
}
