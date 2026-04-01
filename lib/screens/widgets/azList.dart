import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';

class _AZGridRow<T extends ISuspensionBean> extends ISuspensionBean {
  _AZGridRow({required this.items, required this.tag, required this.idxs});

  final List<T> items;
  final String tag;
  final List<int> idxs;

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
    this.gridCrossAxisCount = 1,
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
  List<_AZGridRow<T>>? _cachedGridRows;

  @override
  void didUpdateWidget(AZList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Invalidate the cache whenever the source data or column count changes.
    if (!identical(widget.items, oldWidget.items) || widget.gridCrossAxisCount != oldWidget.gridCrossAxisCount) {
      _cachedGridRows = null;
    }
  }

  // Groups flat items into chunks of rows per suspension tag
  List<_AZGridRow<T>> _buildGridRows() {
    final List<_AZGridRow<T>> rows = [];
    String currentTag = '';
    var currentChunk = <T>[];
    var currIdxs = <int>[];

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final tag = item.getSuspensionTag();
      if (tag != currentTag) {
        if (currentChunk.isNotEmpty) {
          rows.add(_AZGridRow(items: currentChunk, idxs: currIdxs, tag: currentTag));
          currentChunk = [];
          currIdxs = [];
        }
        currentTag = tag;
      }

      currentChunk.add(item);
      currIdxs.add(i);
      if (currentChunk.length == widget.gridCrossAxisCount) {
        rows.add(_AZGridRow(items: currentChunk, idxs: currIdxs, tag: currentTag));
        currentChunk = [];
        currIdxs = [];
      }
    }

    if (currentChunk.isNotEmpty) {
      rows.add(_AZGridRow(items: currentChunk, idxs: currIdxs, tag: currentTag));
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

    final List<ISuspensionBean> displayItems = widget.gridCrossAxisCount > 1 ? _getGridRows() : widget.items;

    return AzListView(
      data: displayItems,
      itemCount: displayItems.length,
      indexBarData: widget.showIndexedBar ? SuspensionUtil.getTagIndexList(widget.items) : [],
      indexBarWidth: AZList.indexBarWidth,
      itemBuilder: (context, index) {
        if (widget.gridCrossAxisCount > 1) {
          final row = displayItems[index] as _AZGridRow<T>;
          return Padding(
            padding: const EdgeInsets.only(right: AZList.indexBarWidth),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...row.items.asMap().entries.map((entry) {
                  return Expanded(child: widget.itemBuilder(context, entry.value, row.idxs[entry.key]));
                }),
                ...List.generate(
                  widget.gridCrossAxisCount - row.items.length,
                  (_) => const Expanded(child: SizedBox.shrink()),
                ),
              ],
            ),
          );
        }

        return widget.itemBuilder(context, displayItems[index] as T, index);
      },
      indexBarOptions: IndexBarOptions(
        needRebuild: true,
        selectTextStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        ignoreDragCancel: true,
        downTextStyle: TextStyle(fontSize: 12, color: scheme.onPrimary),
        downItemDecoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
        indexHintWidth: 80,
        indexHintHeight: 80,
        indexHintDecoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
        indexHintTextStyle: TextStyle(fontSize: 24, color: scheme.onPrimaryContainer, fontWeight: FontWeight.bold),
      ),
    );
  }
}
