import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/color.dart';
import 'package:music_player/screens/mainTab.dart';
import 'package:music_player/screens/permissions.dart';
import 'package:music_player/services/AudioPlayerHandlerService.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';
import 'package:music_player/services/PlayerStateService.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAudioService();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    disposeLocatorService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      home: const PermissionGate(),
    );
  }
}
