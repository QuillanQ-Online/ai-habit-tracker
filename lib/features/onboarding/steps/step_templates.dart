import 'package:flutter/material.dart';

import '../../../shared/models/habit_template.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/step_scaffold.dart';

class TemplatePickerStep extends StatelessWidget {
  const TemplatePickerStep({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.templates,
    required this.selectedHabits,
    required this.onToggle,
    required this.onContinue,
    required this.onBack,
    required this.onSkip,
  });

  final int stepIndex;
  final int totalSteps;
  final List<HabitTemplate> templates;
  final List<SelectedHabit> selectedHabits;
  final void Function(HabitTemplate template) onToggle;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final selectedIds = selectedHabits.map((habit) => habit.templateId).toSet();
    final error = templateSelectionError(selectedIds.length);
    return StepScaffold(
      stepIndex: stepIndex,
      totalSteps: totalSteps,
      title: 'Pick a few habits to jump-start',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose up to three. You can always add more later.'),
          const SizedBox(height: 16),
          ...templates.map((template) {
            final isSelected = selectedIds.contains(template.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onToggle(template),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(template.description),
                            const SizedBox(height: 8),
                            Text(
                              'Target: ${template.defaultTarget} ${template.unit.label}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => onToggle(template),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      onPrimaryPressed: onContinue,
      primaryLabel: 'Continue',
      onBack: onBack,
      secondaryLabel: 'Back',
      tertiaryLabel: 'Skip templates',
      onTertiaryPressed: onSkip,
      isPrimaryEnabled: selectedIds.length <= maxTemplateSelection,
      helperText: error,
    );
  }
}
