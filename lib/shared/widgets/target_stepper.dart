import 'package:flutter/material.dart';

/// Simple +/- stepper to adjust numeric targets.
class TargetStepper extends StatelessWidget {
  const TargetStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 1000,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  void _change(int delta) {
    final newValue = (value + delta).clamp(min, max);
    onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > min ? () => _change(-1) : null,
        ),
        Text(
          '$value',
          style: theme.textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < max ? () => _change(1) : null,
        ),
      ],
    );
  }
}
