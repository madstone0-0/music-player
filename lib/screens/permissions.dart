import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/LocatorService.dart';
import '../services/MusicService.dart';
import '../services/PlayerStateService.dart';
import 'mainTab.dart';

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
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

    getIt<PlayerStateService>().init();
    await getIt<MusicService>().restoreLastSession();

    Get.off(() => MainTab());
  }

  /// Request the necessary storage permissions based on the Android SDK version.
  Future<bool> _requestStoragePermission() async {
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

    if (sdk >= 30) {
      if (sdk >= 33) await Permission.audio.request();

      if (await Permission.manageExternalStorage.isGranted) return true;
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }

    final results = await [Permission.audio, Permission.storage].request();
    return results.values.any((s) => s.isGranted || s == PermissionStatus.limited);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
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
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(scheme.primary), strokeWidth: 2),
          const SizedBox(height: 20),
          Text('Setting up…', style: TextStyle(color: scheme.onSurface, fontSize: 13)),
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, color: scheme.onSurface, size: 52),
          const SizedBox(height: 24),
          Text(
            'Storage access required',
            style: TextStyle(color: scheme.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'This app needs full storage access to read and tag '
            'your audio files. You will be taken to a system '
            'settings screen — enable "Allow access to manage all files".',
            style: TextStyle(color: scheme.onSurface, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.onSurface,
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
            child: Text('Open app settings', style: TextStyle(color: scheme.onSurface, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
