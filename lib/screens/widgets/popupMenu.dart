import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopupMenuItemData {
  PopupMenuItemData({required this.value, required this.icon, required this.label});

  final int value;
  final IconData icon;
  final String label;
}

class PopupMenu extends StatelessWidget {
  const PopupMenu({
    super.key,
    required this.scheme,
    required this.items,
    required this.onSelected,
    this.longPress = false,
  });

  final ColorScheme scheme;
  final List<PopupMenuItemData> items;
  final void Function(int) onSelected;
  final bool longPress;

  @override
  Widget build(BuildContext context) {
    if (longPress) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items
              .map(
                (item) =>
                ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(item.value);
                    },
                    leading: Icon(item.icon, size: 18, color: scheme.onSurfaceVariant),
            title: Text(item.label, style: TextStyle(color: scheme.onSurface, fontSize: 13)),
          ),
        )
            .toList(),
      ),
    );
    }

    return PopupMenuButton<int>(
    color: scheme.surfaceContainerHigh,
    elevation: 2,
    offset: const Offset(-8, 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    icon: Icon(Icons.more_vert_rounded, color: scheme.onSurface),
    onSelected: onSelected,
    itemBuilder: (_) => items.map((item) => _menuItem(item.value, item.icon, item.label)).toList(),
    );
    }

  PopupMenuItem<int> _menuItem(int value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: scheme.onSurface, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
