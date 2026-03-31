import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SortChipOption<T> {
  const SortChipOption({required this.label, required this.asc, required this.desc});

  final String label;
  final T asc;
  final T desc;
}

class SortSection<T> extends StatelessWidget {
  const SortSection({super.key, required this.options, required this.currentMode, required this.onToggle});

  final List<SortChipOption<T>> options;

  final Rx<T> currentMode;

  final void Function(String label) onToggle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _SortChip<T>(option: options[i], currentMode: currentMode, onToggle: onToggle),
          ],
        ],
      ),
    );
  }
}

class _SortChip<T> extends StatelessWidget {
  const _SortChip({required this.option, required this.currentMode, required this.onToggle});

  final SortChipOption<T> option;
  final Rx<T> currentMode;
  final void Function(String label) onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Obx(() {
      final isSelected = currentMode.value == option.asc || currentMode.value == option.desc;
      final isAsc = currentMode.value == option.asc;

      return ChoiceChip(
        label: Text(option.label),
        selected: isSelected,
        onSelected: (_) => onToggle(option.label),
        showCheckmark: false,
        selectedColor: scheme.secondaryContainer,
        backgroundColor: scheme.surface,
        avatar: isSelected
            ? Icon(
                isAsc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 18,
                color: scheme.onSecondaryContainer,
              )
            : null,
        labelStyle: text.labelLarge?.copyWith(
          color: isSelected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isSelected ? Colors.transparent : scheme.outlineVariant),
        ),
      );
    });
  }
}
