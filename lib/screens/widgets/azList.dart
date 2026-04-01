import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';

class _AZGridRow<T extends ISuspensionBean> extends ISuspensionBean {
  final List<T> items;
  // Pre-computed original indices avoid an O(n) indexOf search per item.
  final List<int> indices;
  final String tag;

  _AZGridRow({required this.items, required this.indices, required this.tag});

  @override
  String getSuspensionTag() => tag;
}

class AZList<T extends ISuspensionBean> extends StatefulWidget {
  const AZList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.emptyMessage = 'No items found',
    this.showIndexedBar = true,
    this.gridCrossAxisCount = 1, // Default to List mode
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String emptyMessage;
  final bool showIndexedBar;
  final int gridCrossAxisCount;

  static const double indexBarWidth = 28.0;
  static const EdgeInsets itemPadding = EdgeInsets.only(bottom: 4.0, right: indexBarWidth);

  @override
  State<AZList<T>> createState() => _AZListState<T>();
}

class _AZListState<T extends ISuspensionBean> extends State<AZList<T>> {
  // Cached grid rows so _buildGridRows() is never called during an animation frame.
  List<_AZGridRow<T>>? _cachedGridRows;

  @override
  void didUpdateWidget(AZList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Invalidate the cache whenever the source data or column count changes.
    if (!identical(widget.items, oldWidget.items) ||
        widget.gridCrossAxisCount != oldWidget.gridCrossAxisCount) {
      _cachedGridRows = null;
    }
  }

  // Groups flat items into rows, recording each item's original index so
  // callers can avoid an O(n) indexOf() call per item.
  List<_AZGridRow<T>> _buildGridRows() {
    final List<_AZGridRow<T>> rows = [];
    String currentTag = '';
    var currentChunk = <T>[];
    var currentIndices = <int>[];

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final tag = item.getSuspensionTag();
      if (tag != currentTag) {
        if (currentChunk.isNotEmpty) {
          rows.add(_AZGridRow(items: currentChunk, indices: currentIndices, tag: currentTag));
          currentChunk = [];
          currentIndices = [];
        }
        currentTag = tag;
      }

      currentChunk.add(item);
      currentIndices.add(i);
      if (currentChunk.length == widget.gridCrossAxisCount) {
        rows.add(_AZGridRow(items: currentChunk, indices: currentIndices, tag: currentTag));
        currentChunk = [];
        currentIndices = [];
      }
    }

    if (currentChunk.isNotEmpty) {
      rows.add(_AZGridRow(items: currentChunk, indices: currentIndices, tag: currentTag));
    }

    SuspensionUtil.setShowSuspensionStatus(rows);
    return rows;
  }

  List<_AZGridRow<T>> _getGridRows() => _cachedGridRows ??= _buildGridRows();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (widget.items.isEmpty) {
      return Center(
        child: Text(widget.emptyMessage, style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant)),
      );
    }

    // Determine the data list to render based on layout mode.
    final List<ISuspensionBean> displayItems =
        widget.gridCrossAxisCount > 1 ? _getGridRows() : widget.items;

    return AzListView(
      data: displayItems,
      itemCount: displayItems.length,
      indexBarData: widget.showIndexedBar ? SuspensionUtil.getTagIndexList(widget.items) : [],
      indexBarWidth: AZList.indexBarWidth,
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
        if (widget.gridCrossAxisCount > 1) {
          final row = displayItems[index] as _AZGridRow<T>;
          return Padding(
            // Ensure the grid doesn't overlap the right-most AZ bar
            padding: const EdgeInsets.only(right: AZList.indexBarWidth),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...row.items.asMap().entries.map((entry) {
                  return Expanded(
                    child: widget.itemBuilder(context, entry.value, row.indices[entry.key]),
                  );
                }),
                ...List.generate(
                  widget.gridCrossAxisCount - row.items.length,
                  (_) => const Expanded(child: SizedBox.shrink()),
                ),
              ],
            ),
          );
        }

        // Standard List mode
        return widget.itemBuilder(context, displayItems[index] as T, index);
      },
    );
  }
}
