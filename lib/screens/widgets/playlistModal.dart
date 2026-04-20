import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/playlist.dart';
import 'package:music_player/intents/playlistModal.dart';

class PlaylistModal extends StatefulWidget {
  const PlaylistModal({super.key, required this.intent});

  final PlaylistAddIntent intent;

  static Future<void> open(BuildContext context, PlaylistAddIntent intent) {
    final scheme = Theme.of(context).colorScheme;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PlaylistModal(intent: intent),
    );
  }

  @override
  State<PlaylistModal> createState() => _PlaylistModalState();
}

class _PlaylistModalState extends State<PlaylistModal> {
  late final String _tag;
  late final PlaylistModalViewModel vm;

  @override
  void initState() {
    super.initState();
    _tag = UniqueKey().toString();
    vm = Get.put(PlaylistModalViewModel(intent: widget.intent), tag: _tag);
  }

  @override
  void dispose() {
    if (Get.isRegistered<PlaylistModalViewModel>(tag: _tag)) {
      Get.delete<PlaylistModalViewModel>(tag: _tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + viewInsets),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                vm.headline,
                style: text.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vm.description,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              _NewPlaylistButton(onCreate: _handleCreatePlaylist, vm: vm),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (vm.playlists.isEmpty) {
                    return _EmptyState(onCreate: _handleCreatePlaylist);
                  }

                  return ListView.separated(
                    itemCount: vm.playlists.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, idx) => _PlaylistTile(
                      item: vm.playlists[idx],
                      vm: vm,
                      onTap: () => _handleAdd(vm.playlists[idx]),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAdd(PlaylistWithCount item) async {
    final messenger = ScaffoldMessenger.of(context);
    final scheme = Theme.of(context).colorScheme;

    try {
      final added = await vm.addToPlaylist(item.playlist.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Added $added ${added == 1 ? 'track' : 'tracks'} to "${item.playlist.name}".'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: scheme.errorContainer,
          content: Text(_errorMessage(e), style: TextStyle(color: scheme.onErrorContainer)),
        ),
      );
    }
  }

  Future<void> _handleCreatePlaylist() async {
    final name = await _promptName();
    if (name == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final scheme = Theme.of(context).colorScheme;

    try {
      final result = await vm.createAndAdd(name);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Added ${result.$2} ${result.$2 == 1 ? 'track' : 'tracks'} to "$name".'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: scheme.errorContainer,
          content: Text(_errorMessage(e), style: TextStyle(color: scheme.onErrorContainer)),
        ),
      );
    }
  }

  Future<String?> _promptName() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surface,
          title: const Text('New playlist'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Playlist name', hintText: 'Enter a name'),
              validator: _validateName,
              onFieldSubmitted: (_) {
                if (formKey.currentState!.validate()) Navigator.of(dialogContext).pop(true);
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) return controller.text.trim();
    return null;
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required';
    if (v.length > 80) return 'Name is too long';
    return null;
  }

  String _errorMessage(Object e) {
    if (e is StateError) return e.message;
    if (e is ArgumentError) return e.message ?? 'Invalid input';
    return 'Something went wrong. Please try again.';
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({required this.item, required this.vm, required this.onTap});

  final PlaylistWithCount item;
  final PlaylistModalViewModel vm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Obx(() {
      final isBusy = vm.processingId.value == item.playlist.id;

      return ListTile(
        onTap: isBusy ? null : onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: scheme.surfaceContainerLow,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.queue_music_rounded, color: scheme.onSecondaryContainer),
        ),
        title: Text(
          item.playlist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.titleSmall?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${item.trackCount} track${item.trackCount == 1 ? '' : 's'}',
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        trailing: isBusy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              )
            : Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
      );
    });
  }
}

class _NewPlaylistButton extends StatelessWidget {
  const _NewPlaylistButton({required this.onCreate, required this.vm});

  final VoidCallback onCreate;
  final PlaylistModalViewModel vm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(
      () => FilledButton.icon(
        onPressed: vm.isCreating.value ? null : onCreate,
        icon: vm.isCreating.value
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.onPrimary,
                ),
              )
            : const Icon(Icons.add_rounded),
        label: const Text('New playlist'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.queue_music_rounded, size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'No playlists yet',
              style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Create a playlist to save this selection.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Create playlist'),
            ),
          ],
        ),
      ),
    );
  }
}
