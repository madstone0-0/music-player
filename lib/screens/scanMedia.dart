import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/models/scanMedia.dart';

class ScanMedia extends StatefulWidget {
  const ScanMedia({super.key});

  @override
  State<ScanMedia> createState() => _ScanMediaState();
}

class _ScanMediaState extends State<ScanMedia> {
  final vm = Get.put(ScanMediaViewModel());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Scan Media',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        return switch (vm.status.value) {
          ScanStatus.idle => _IdleView(vm: vm),
          ScanStatus.scanning => _ScanningView(vm: vm),
          ScanStatus.done => _DoneView(vm: vm),
          ScanStatus.error => _ErrorView(vm: vm),
        };
      }),
    );
  }
}

// ─── Idle View (with Overwrite Toggle) ────────────────────────────────────────

class _IdleView extends StatelessWidget {
  const _IdleView({required this.vm});

  final ScanMediaViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search_rounded, size: 72, color: scheme.primary),
          const SizedBox(height: 28),
          Text(
            'Scan your device for audio files',
            style: text.titleLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'This will read your Music folder and index all audio files into the library.',
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // ── Overwrite Toggle ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Obx(
              () => SwitchListTile(
                value: vm.overwrite.value,
                onChanged: (val) => vm.overwrite.value = val,
                activeColor: scheme.primary,
                title: Text('Force Overwrite', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Re-read ID3 tags for all files, even if they haven\'t changed.',
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ── Action Button ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: vm.startScan,
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Start Scan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scanning View ────────────────────────────────────────────────────────────

class _ScanningView extends StatelessWidget {
  const _ScanningView({required this.vm});

  final ScanMediaViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated progress ring
          Obx(
            () => SizedBox.square(
              dimension: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: vm.total.value == 0 ? null : vm.progress,
                    strokeWidth: 6,
                    color: scheme.primary,
                    backgroundColor: scheme.primaryContainer,
                  ),
                  if (vm.total.value > 0)
                    Text(
                      '${(vm.progress * 100).round()}%',
                      style: text.headlineSmall?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          Obx(
            () => Text(
              vm.total.value == 0 ? 'Discovering files…' : '${vm.currentIndex.value} of ${vm.total.value} files',
              style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),

          // Currently processing file name
          Obx(() {
            final name = vm.currentPath.value.isNotEmpty ? vm.currentPath.value.split('/').last : '';
            return Text(
              name,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            );
          }),
          const SizedBox(height: 32),

          // Linear bar below for granular progress
          Obx(
            () => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: vm.total.value == 0 ? null : vm.progress,
                minHeight: 4,
                color: scheme.primary,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Done View ────────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  const _DoneView({required this.vm});

  final ScanMediaViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: scheme.primary, size: 72),
          const SizedBox(height: 24),
          Text(
            'Scan complete',
            style: text.headlineSmall?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              '${vm.doneCount.value} tracks synced with library',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => Get.offAllNamed('/MainTab'),
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Go to Library', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: vm.reset,
            child: Text('Scan again', style: text.labelLarge?.copyWith(color: scheme.primary)),
          ),
        ],
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.vm});

  final ScanMediaViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.error, size: 72),
          const SizedBox(height: 24),
          Text(
            'Scan failed',
            style: text.headlineSmall?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(8)),
              child: Text(
                vm.errorMessage.value,
                style: text.bodySmall?.copyWith(color: scheme.onErrorContainer),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: vm.startScan,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
