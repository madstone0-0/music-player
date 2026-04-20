import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_player/db/tables/trackMapper.dart';
import 'package:music_player/models/home.dart';
import 'package:music_player/screens/playlistTracks.dart';
import 'package:music_player/screens/widgets/search.dart';
import 'package:music_player/screens/widgets/searchResults.dart';
import 'package:music_player/screens/widgets/trackRow.dart';
import 'package:music_player/services/LocatorService.dart';
import 'package:music_player/services/MusicService.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final vm = Get.put(HomeViewModel());
  final _plySrv = getIt<MusicService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              "Home",
              style: textTheme.titleLarge?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            Expanded(child: _SearchBarLauncher(onTap: _openSearch)),
          ],
        ),
      ),
      body: Obx(() {
        final slivers = <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text('Good ${_greeting()},', style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurface)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Here’s your listening at a glance',
                style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ];

        if (vm.recentPlaylists.isNotEmpty) {
          slivers.addAll(_buildPlaylistSection(context));
        }

        if (vm.mostPlayedTracks.isNotEmpty) {
          slivers.addAll(_buildMostPlayedSection(context));
        }

        if (vm.recentTracks.isNotEmpty) {
          slivers.addAll(_buildRecentPlaysSection(context));
        }

        if (!vm.hasContent) {
          slivers.add(_buildEmptyState(context));
        }

        slivers.add(SliverToBoxAdapter(
          child: SizedBox(height: 16 + MediaQuery.paddingOf(context).bottom),
        ));

        return CustomScrollView(slivers: slivers);
      }),
    );
  }

  void _openSearch() {
    Get.to(
          () => SearchScreen(
        hint: 'Search songs, albums, artists…',
        hintTitle: 'Search your library',
        hintSubtitle: 'Find songs, albums and artists',
        resultsBuilder: (context, query) => SearchResults(query: query),
      ),
      transition: Transition.fadeIn,
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  List<Widget> _buildPlaylistSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final items = vm.recentPlaylists;

    return [
      _SectionHeader(title: 'Recently Played Playlists', padding: const EdgeInsets.fromLTRB(16, 8, 16, 12)),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 156,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return _PlaylistCard(
                item: item,
                scheme: scheme,
                onTap: () => Get.to(
                      () => const PlaylistTracks(),
                  arguments: {'playlistId': item.playlist.id},
                  transition: Transition.rightToLeftWithFade,
                ),
                lastPlayedLabel: _formatRelativeTime(item.lastPlayed),
              );
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildMostPlayedSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final items = vm.mostPlayedTracks;

    return [
      _SectionHeader(title: 'Most Played Tracks', padding: const EdgeInsets.fromLTRB(16, 14, 16, 8)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final stat = items[index];
            final track = stat.track.toMediaItem();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TrackRow(
                track: track,
                onPressed: () => _plySrv.playOne(stat.track),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _PlayCountPill(count: stat.playCount, scheme: scheme, text: text),
                    if (stat.lastPlayed != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _formatRelativeTime(stat.lastPlayed!),
                          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _buildRecentPlaysSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final entries = vm.recentTracks;

    return [
      _SectionHeader(title: 'Recently Played Tracks', padding: const EdgeInsets.fromLTRB(16, 14, 16, 8)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverList.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final track = entry.track.toMediaItem();
            final playedAt = entry.entry.playedAt.toLocal();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TrackRow(
                track: track,
                onPressed: () => _plySrv.playOne(entry.track),
                trailing: Text(
                  _formatRecentTimestamp(playedAt),
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  SliverFillRemaining _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.headphones_rounded, size: 56, color: scheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'Nothing to show yet',
                style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Play some music to see your most played tracks and playlists appear here.',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime value) {
    final now = DateTime.now();
    final difference = now.difference(value);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return '1 day ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return DateFormat.yMMMd().format(value);
  }

  String _formatRecentTimestamp(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final playedDay = DateTime(value.year, value.month, value.day);

    if (playedDay == today) {
      return DateFormat.jm().format(value);
    }
    if (today.subtract(const Duration(days: 1)) == playedDay) {
      return 'Yesterday';
    }
    return DateFormat.MMMd().format(value);
  }
}

class _SearchBarLauncher extends StatelessWidget {
  const _SearchBarLauncher({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SearchBar(
        enabled: false,
        hintText: 'Search songs, albums…',
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.07)),
        overlayColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.04)),
        side: WidgetStatePropertyAll(BorderSide(color: scheme.onSurface.withValues(alpha: 0.08))),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
        textStyle: WidgetStatePropertyAll(TextStyle(color: scheme.onSurface, fontSize: 14)),
        hintStyle: WidgetStatePropertyAll(TextStyle(color: scheme.onSurface.withValues(alpha: 0.28), fontSize: 14)),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(Icons.search_rounded, size: 18, color: scheme.onSurface.withValues(alpha: 0.28)),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 12)});

  final String title;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Text(
          title,
          style: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.item,
    required this.scheme,
    required this.onTap,
    required this.lastPlayedLabel,
  });

  final HomePlaylistItem item;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final String lastPlayedLabel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final trackCountLabel = item.trackCount == 1 ? '1 track' : '${item.trackCount} tracks';

    return SizedBox(
      width: 200,
      child: Card(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.queue_music_rounded, color: scheme.onSecondaryContainer),
                    ),
                    const Spacer(),
                    Text(
                      lastPlayedLabel,
                      style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.playlist.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(trackCountLabel, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayCountPill extends StatelessWidget {
  const _PlayCountPill({required this.count, required this.scheme, required this.text});

  final int count;
  final ColorScheme scheme;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 play' : '$count plays';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: text.labelMedium?.copyWith(color: scheme.onSurface),
      ),
    );
  }
}
