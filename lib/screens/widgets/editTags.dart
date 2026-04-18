import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/AudioTaggingService.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

class EditTags extends StatefulWidget {
  const EditTags({super.key, required this.track});

  final TrackData track;

  static Future<TrackData?> open(BuildContext context, TrackData track) {
    final scheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<TrackData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      showDragHandle: true,
      builder: (_) => EditTags(track: track),
    );
  }

  @override
  State<EditTags> createState() => _EditTagsState();
}

class _EditTagsState extends State<EditTags> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _albumArtistCtrl = TextEditingController();
  final _albumCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _trackNoCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  bool _saving = false;

  TrackData get _track => widget.track;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = _track.title;
    _artistCtrl.text = _track.artist ?? '';
    _albumArtistCtrl.text = _track.albumArtist ?? '';
    _albumCtrl.text = _track.album ?? '';
    _genreCtrl.text = _track.genre ?? '';
    _trackNoCtrl.text = _track.trackNo?.toString() ?? '';
    _yearCtrl.text = _track.year?.toString() ?? '';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _albumArtistCtrl.dispose();
    _albumCtrl.dispose();
    _genreCtrl.dispose();
    _trackNoCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + viewInsets),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit tags',
                  style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update fields that are writable for this track.',
                  style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Title cannot be empty';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _artistCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Artist'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _albumArtistCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Album Artist'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _albumCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Album'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _genreCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Genre'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _trackNoCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Track #'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => _validateNumber(value, 'track number'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _yearCtrl,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Year'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => _validateNumber(value, 'year'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _saving ? null : _handleSave,
                      icon: _saving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onPrimary),
                            )
                          : const Icon(Icons.save_rounded),
                      label: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateNumber(String? value, String label) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final parsed = int.tryParse(trimmed);
    if (parsed == null) return 'Enter a valid $label';
    if (parsed < 0) return 'Value cannot be negative';
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final scheme = Theme.of(context).colorScheme;

    try {
      final updated = _track.copyWith(
        title: _titleCtrl.text.trim(),
        artist: Value(_emptyToNull(_artistCtrl.text)),
        albumArtist: Value(_emptyToNull(_albumArtistCtrl.text)),
        album: Value(_emptyToNull(_albumCtrl.text)),
        genre: Value(_emptyToNull(_genreCtrl.text)),
        trackNo: Value(_parseOptionalInt(_trackNoCtrl.text)),
        year: Value(_parseOptionalInt(_yearCtrl.text)),
      );

      await AudioTaggingService.write(updated);
      final lastModified = await File(updated.path).lastModified();

      final repo = getIt<TrackRepository>();
      await repo.updateFromFile(
        id: updated.id,
        title: updated.title,
        artist: updated.artist,
        albumArtist: updated.albumArtist,
        album: updated.album,
        genre: updated.genre,
        trackNo: updated.trackNo,
        year: updated.year,
        lastModified: lastModified,
      );

      await getIt<MusicService>().syncQueueWithDb();

      if (!mounted) return;
      Navigator.of(context).pop(updated);
      messenger.showSnackBar(const SnackBar(content: Text('Tags updated')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: scheme.errorContainer,
          content: Text('Failed to save tags: $e', style: TextStyle(color: scheme.onErrorContainer)),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  int? _parseOptionalInt(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }
}
