import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/db/daos/playlist.dart';
import 'package:music_player/models/playlists.dart';
import 'package:music_player/screens/playlistTracks.dart';
import 'package:music_player/screens/widgets/sort.dart';

class Playlists extends StatefulWidget {
  const Playlists({super.key});

  @override
  State<Playlists> createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists> with AutomaticKeepAliveClientMixin {
  late final PlaylistViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = Get.isRegistered<PlaylistViewModel>() ? Get.find<PlaylistViewModel>() : Get.put(PlaylistViewModel());
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _showCreatePlaylistDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final created = await showDialog<bool>(
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
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Name is required';
                if (v.length > 80) return 'Name is too long';
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (created == true) {
      await vm.createPlaylist(controller.text.trim());
    }

    await WidgetsBinding.instance.endOfFrame;
    controller.dispose();
  }

  Future<void> _showRenamePlaylistDialog(PlaylistWithCount item) async {
    final controller = TextEditingController(text: item.playlist.name);
    final formKey = GlobalKey<FormState>();

    final renamed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surface,
          title: const Text('Rename playlist'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Playlist name'),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Name is required';
                if (v.length > 80) return 'Name is too long';
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (renamed == true) {
      await vm.renamePlaylist(item.playlist.id, controller.text.trim());
    }

    await WidgetsBinding.instance.endOfFrame;
    controller.dispose();
  }

  Future<void> _confirmDeletePlaylist(PlaylistWithCount item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surface,
          title: const Text('Delete playlist'),
          content: Text(
            'Delete "${item.playlist.name}"? This will remove ${item.trackCount} track${item.trackCount == 1 ? '' : 's'} from the playlist.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton.tonal(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
          ],
        );
      },
    );

    if (confirmed == true) {
      await vm.deletePlaylist(item.playlist.id);
    }
  }

  void _showPlaylistMenu(PlaylistWithCount item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: const Text('Rename'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showRenamePlaylistDialog(item);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  iconColor: scheme.error,
                  textColor: scheme.error,
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDeletePlaylist(item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ColoredBox(
      color: scheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SortSection<PlaylistSortMode>(
                  options: const [
                    SortChipOption(label: 'Name', asc: PlaylistSortMode.nameAsc, desc: PlaylistSortMode.nameDesc),
                    SortChipOption(
                      label: 'Created',
                      asc: PlaylistSortMode.createdAtAsc,
                      desc: PlaylistSortMode.createdAtDesc,
                    ),
                    SortChipOption(
                      label: 'Updated',
                      asc: PlaylistSortMode.updatedAtAsc,
                      desc: PlaylistSortMode.updatedAtDesc,
                    ),
                  ],
                  currentMode: vm.sortMode,
                  onToggle: vm.toggleSort,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton.filledTonal(
                  onPressed: _showCreatePlaylistDialog,
                  tooltip: 'New playlist',
                  icon: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),
          Expanded(
            child: Obx(() {
              if (vm.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.playlists.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.queue_music_rounded, size: 56, color: scheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          'No playlists yet',
                          style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a playlist to organize tracks from your library.',
                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _showCreatePlaylistDialog,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Create playlist'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                itemCount: vm.playlists.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = vm.playlists[index];
                  final subtitle = item.trackCount == 1 ? '1 track' : '${item.trackCount} tracks';

                  return Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: scheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.queue_music_rounded, color: scheme.onSecondaryContainer),
                      ),
                      title: Text(
                        item.playlist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(subtitle, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                      trailing: IconButton(
                        tooltip: 'Playlist options',
                        icon: const Icon(Icons.more_vert_rounded),
                        onPressed: () => _showPlaylistMenu(item),
                      ),
                      onTap: () {
                        Get.to(
                          () => const PlaylistTracks(),
                          arguments: {'playlistId': item.playlist.id},
                          transition: Transition.rightToLeftWithFade,
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
