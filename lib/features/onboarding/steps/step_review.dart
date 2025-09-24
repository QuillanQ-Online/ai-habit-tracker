import 'package:flutter/material.dart';

import '../../../shared/models/habit_template.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/step_scaffold.dart';
import '../../../shared/widgets/target_stepper.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.habits,
    required this.onBack,
    required this.onConfirm,
    required this.onUpdateTarget,
    required this.onUpdateWindows,
  });

  final int stepIndex;
  final int totalSteps;
  final List<SelectedHabit> habits;
  final VoidCallback onBack;
  final VoidCallback onConfirm;
  final void Function(String templateId, int target) onUpdateTarget;
  final void Function(String templateId, List<TimeWindowSelection> windows) onUpdateWindows;

  @override
  Widget build(BuildContext context) {
    final helper = windowsValidationError(habits);
    return StepScaffold(
      stepIndex: stepIndex,
      totalSteps: totalSteps,
      title: 'Review your plan',
      child: habits.isEmpty
          ? const Text('No starter habits selected. You\'re good to go!')
          : Column(
              children: [
                for (final habit in habits)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(habit.name, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Daily target (${habit.unit.label})'),
                              TargetStepper(
                                value: habit.target,
                                onChanged: (value) => onUpdateTarget(habit.templateId, value),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final preset in TimeWindowPreset.values)
                                FilterChip(
                                  label: Text(_presetLabel(preset)),
                                  selected: habit.windows.any(
                                    (window) => window.isPreset && window.preset == preset,
                                  ),
                                  onSelected: (selected) {
                                    final updated = [...habit.windows];
                                    updated.removeWhere(
                                      (window) => window.isPreset && window.preset == preset,
                                    );
                                    if (selected) {
                                      updated.add(TimeWindowSelection.preset(preset));
                                    }
                                    onUpdateWindows(habit.templateId, updated);
                                  },
                                ),
                            ],
                          ),
                          if (habit.windows.any((window) => window.isCustom)) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                for (final window in habit.windows.where((window) => window.isCustom))
                                  InputChip(
                                    label: Text(window.displayLabel),
                                    onDeleted: () {
                                      final updated = [...habit.windows]..remove(window);
                                      onUpdateWindows(habit.templateId, updated);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      onPrimaryPressed: onConfirm,
      primaryLabel: 'Looks good',
      onBack: onBack,
      secondaryLabel: 'Edit again',
      isPrimaryEnabled: helper == null,
      helperText: helper,
    );
  }
}

String _presetLabel(TimeWindowPreset preset) {
  switch (preset) {
    case TimeWindowPreset.morning:
      return 'Morning';
    case TimeWindowPreset.afternoon:
      return 'Afternoon';
    case TimeWindowPreset.evening:
      return 'Evening';
  }
}
