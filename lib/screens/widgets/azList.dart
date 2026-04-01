import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';

class _AZGridRow<T extends ISuspensionBean> extends ISuspensionBean {
  final List<T> items;
  final String tag;

  _AZGridRow({required this.items, required this.tag});

  @override
  String getSuspensionTag() => tag;
}

class AZList<T extends ISuspensionBean> extends StatelessWidget {
  const AZList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.emptyMessage = 'No items found',
    this.showIndexedBar = true,
    this.gridCrossAxisCount = 1,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String emptyMessage;
  final bool showIndexedBar;
  final int gridCrossAxisCount;

  static const double indexBarWidth = 28.0;
  static const EdgeInsets itemPadding = EdgeInsets.only(bottom: 4.0, right: indexBarWidth);

  // Groups flat items into chunks of rows per suspension tag
  List<_AZGridRow<T>> _buildGridRows() {
    List<_AZGridRow<T>> rows = [];
    String currentTag = '';
    List<T> currentChunk = [];

    for (var item in items) {
      final tag = item.getSuspensionTag();
      if (tag != currentTag) {
        if (currentChunk.isNotEmpty) {
          rows.add(_AZGridRow(items: currentChunk, tag: currentTag));
          currentChunk = [];
        }
        currentTag = tag;
      }

      currentChunk.add(item);
      if (currentChunk.length == gridCrossAxisCount) {
        rows.add(_AZGridRow(items: currentChunk, tag: currentTag));
        currentChunk = [];
      }
    }

    if (currentChunk.isNotEmpty) {
      rows.add(_AZGridRow(items: currentChunk, tag: currentTag));
    }

    SuspensionUtil.setShowSuspensionStatus(rows);
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant)),
      );
    }

    // Determine the data list to render based on layout mode
    final List<ISuspensionBean> displayItems = gridCrossAxisCount > 1 ? _buildGridRows() : items;

    return AzListView(
      data: displayItems,
      itemCount: displayItems.length,
      indexBarData: showIndexedBar ? SuspensionUtil.getTagIndexList(items) : [],
      indexBarWidth: indexBarWidth,
      indexBarOptions: IndexBarOptions(
        needRebuild: true,
        selectTextStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        selectItemDecoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
        indexHintAlignment: Alignment.centerRight,
        indexHintOffset: const Offset(-20, 0),
        textStyle: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
      ),
      indexHintBuilder: (context, hint) => Container(
        alignment: Alignment.center,
        width: 60.0,
        height: 60.0,
        decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
        child: Text(
          hint,
          style: TextStyle(color: scheme.onPrimary, fontSize: 28.0, fontWeight: FontWeight.bold),
        ),
      ),
      susItemBuilder: (context, index) {
        final tag = displayItems[index].getSuspensionTag();
        return Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          color: scheme.surface,
          alignment: Alignment.centerLeft,
          child: Text(
            tag,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold),
          ),
        );
      },
      itemBuilder: (context, index) {
        if (gridCrossAxisCount > 1) {
          final row = displayItems[index] as _AZGridRow<T>;
          return Padding(
            // Ensure the grid doesn't overlap the right-most AZ bar
            padding: const EdgeInsets.only(right: indexBarWidth),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  row.items.map((item) {
                    return Expanded(child: itemBuilder(context, item, items.indexOf(item)));
                  }).toList()..addAll(
                    List.generate(
                      gridCrossAxisCount - row.items.length,
                      (_) => const Expanded(child: SizedBox.shrink()),
                    ),
                  ),
            ),
          );
        }

        // Standard List mode
        return itemBuilder(context, displayItems[index] as T, index);
      },
    );
  }
}
