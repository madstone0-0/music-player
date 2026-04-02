import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/common/color.dart';
import 'package:music_player/screens/home.dart';
import 'package:music_player/screens/mainTab.dart';
import 'package:music_player/services/AudioPlayerHandlerService.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';
import 'package:music_player/services/PageManagerService.dart';
import 'package:music_player/services/RouteObserverService.dart';
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
  final _routeOb = RouteObserverService();

  @override
  void dispose() {
    if (getIt.isRegistered<AudioPlayerHandlerService>()) {
      getIt<AudioPlayerHandlerService>().dispose();
    }
    if (getIt.isRegistered<PageManagerService>()) {
      getIt<PageManagerService>().dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      navigatorObservers: [_routeOb],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      home: const _PermissionGate(),
    );
  }
}

class _PermissionGate extends StatefulWidget {
  const _PermissionGate();

  @override
  State<_PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<_PermissionGate> {
  _GateStatus _status = _GateStatus.checking;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final granted = await _requestStoragePermission();

    if (!granted) {
      setState(() => _status = _GateStatus.denied);
      return;
    }

    await setupLocatorService();
    if (!mounted) return;

    getIt<PageManagerService>().init();
    await getIt<MusicService>().restoreLastSession();

    Get.off(() => const MainTab());
  }

  Future<bool> _requestStoragePermission() async {
    final results = await [Permission.audio, Permission.storage].request();

    return results.values.any((s) => s == PermissionStatus.granted || s == PermissionStatus.limited);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      body: switch (_status) {
        _GateStatus.checking => const _CheckingView(),
        _GateStatus.denied => _DeniedView(onRetry: _bootstrap),
      },
    );
  }
}

enum _GateStatus { checking, denied }

class _CheckingView extends StatelessWidget {
  const _CheckingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColor.focus), strokeWidth: 2),
          const SizedBox(height: 20),
          Text('Setting up…', style: TextStyle(color: AppColor.secondaryText, fontSize: 13)),
        ],
      ),
    );
  }
}

class _DeniedView extends StatelessWidget {
  const _DeniedView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, color: AppColor.secondaryText, size: 52),
          const SizedBox(height: 24),
          Text(
            'Storage access required',
            style: TextStyle(color: AppColor.primaryText, fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'This app needs access to your audio files. '
            'Please grant storage permission to continue.',
            style: TextStyle(color: AppColor.secondaryText, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.focus,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Grant Permission',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: openAppSettings,
            child: Text('Open app settings', style: TextStyle(color: AppColor.secondaryText, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
