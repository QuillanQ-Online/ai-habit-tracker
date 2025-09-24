import 'package:flutter/material.dart';

/// Wraps a list of [ChoiceChip]s with selection management.
class ChoiceChipGroup<T> extends StatelessWidget {
  const ChoiceChipGroup({
    super.key,
    required this.options,
    required this.isSelected,
    required this.onSelected,
    this.allowMultiple = true,
    this.spacing = 12,
    this.runSpacing = 12,
  });

  final List<ChipOption<T>> options;
  final bool Function(T value) isSelected;
  final void Function(T value, bool selected) onSelected;
  final bool allowMultiple;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option.label),
            avatar: option.avatar,
            selected: isSelected(option.value),
            onSelected: (selected) => onSelected(option.value, selected),
          ),
      ],
    );
  }
}

class ChipOption<T> {
  const ChipOption({
    required this.value,
    required this.label,
    this.avatar,
  });

  final T value;
  final String label;
  final Widget? avatar;
}
