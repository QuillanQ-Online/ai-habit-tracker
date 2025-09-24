import 'package:flutter/material.dart';

import '../../../shared/models/habit_template.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/step_scaffold.dart';

class TimeWindowsStep extends StatelessWidget {
  const TimeWindowsStep({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.habits,
    required this.onBack,
    required this.onContinue,
    required this.onUpdateWindows,
    required this.onAddCustomTime,
  });

  final int stepIndex;
  final int totalSteps;
  final List<SelectedHabit> habits;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final void Function(String templateId, List<TimeWindowSelection> windows)
  onUpdateWindows;
  final Future<TimeOfDay?> Function(BuildContext context) onAddCustomTime;

  @override
  Widget build(BuildContext context) {
    final helper = windowsValidationError(habits);
    return StepScaffold(
      stepIndex: stepIndex,
      totalSteps: totalSteps,
      title: 'When should we nudge you?',
      onPrimaryPressed: onContinue,
      primaryLabel: 'Continue',
      onBack: onBack,
      secondaryLabel: 'Back',
      isPrimaryEnabled: helper == null,
      helperText: helper,
      child:
          habits.isEmpty
              ? const Text(
                'We\'ll skip reminders for now. You can add habits any time from Today.',
              )
              : Column(
                children:
                    habits
                        .map(
                          (habit) => _HabitWindowsCard(
                            habit: habit,
                            onUpdate: onUpdateWindows,
                            onAddCustomTime: onAddCustomTime,
                          ),
                        )
                        .toList(),
              ),
    );
  }
}

class _HabitWindowsCard extends StatelessWidget {
  const _HabitWindowsCard({
    required this.habit,
    required this.onUpdate,
    required this.onAddCustomTime,
  });

  final SelectedHabit habit;
  final void Function(String templateId, List<TimeWindowSelection> windows)
  onUpdate;
  final Future<TimeOfDay?> Function(BuildContext context) onAddCustomTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presetOptions = TimeWindowPreset.values;
    final windows = habit.windows;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(habit.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final preset in presetOptions)
                  FilterChip(
                    label: Text(_presetLabel(preset)),
                    selected: windows.any(
                      (window) => window.isPreset && window.preset == preset,
                    ),
                    onSelected: (selected) {
                      final updated = [...windows];
                      updated.removeWhere(
                        (window) => window.isPreset && window.preset == preset,
                      );
                      if (selected) {
                        updated.add(TimeWindowSelection.preset(preset));
                      }
                      onUpdate(habit.templateId, updated);
                    },
                  ),
                TextButton.icon(
                  onPressed: () async {
                    final time = await onAddCustomTime(context);
                    if (time != null) {
                      final updated = [
                        ...windows,
                        TimeWindowSelection.custom(time),
                      ];
                      onUpdate(habit.templateId, updated);
                    }
                  },
                  icon: const Icon(Icons.schedule),
                  label: const Text('Custom time'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final window in windows.where((window) => window.isCustom))
                  InputChip(
                    label: Text(window.displayLabel),
                    onDeleted: () {
                      final updated = [...windows]..remove(window);
                      onUpdate(habit.templateId, updated);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Quiet hours ${habit.quietHours == null ? '10:00 PM – 7:00 AM' : _quietLabel(habit.quietHours!)} (adjust later in Settings).',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
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

String _quietLabel(QuietHours hours) {
  return '${_formatTime(hours.start)} – ${_formatTime(hours.end)}';
}

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
