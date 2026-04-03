import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/common/nav.dart';
import 'package:music_player/models/mainTab.dart';
import 'package:music_player/screens/home.dart';
import 'package:music_player/screens/scanMedia.dart';
import 'package:music_player/screens/library.dart';
import 'package:music_player/screens/widgets/miniPlayer.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/PageManagerService.dart';

class MainTab extends StatelessWidget {
  MainTab({super.key});

  final vm = Get.put(MainTabViewModel());
  final playerState = getIt<PlayerStateService>();

  final List<Widget> screens = const [Home(), Library(), ScanMedia()];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          ValueListenableBuilder<MediaItem?>(
            valueListenable: playerState.currentTrackNotifier,
            builder: (context, track, child) {
              final extra = track != null ? kMiniPlayerHeight : 0.0;
              final mq = MediaQuery.of(context);

              return MediaQuery(
                data: mq.copyWith(padding: mq.padding.copyWith(bottom: mq.padding.bottom + extra)),
                child: child!,
              );
            },
            child: Obx(() => IndexedStack(index: vm.selectedIndex.value, children: screens)),
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: vm.selectedIndex.value,
          onDestinationSelected: (val) => vm.changeTab(Tabs.fromVal(val)),
          backgroundColor: scheme.surfaceContainer,
          indicatorColor: scheme.secondaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
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
      ),
    );
  }
}
