import '../models/habit_template.dart';

const int maxTemplateSelection = 3;

String? templateSelectionError(int selectionCount) {
  if (selectionCount > maxTemplateSelection) {
    return 'Pick up to $maxTemplateSelection habits to start.';
  }
  if (selectionCount == maxTemplateSelection) {
    return 'You\'ve hit the $maxTemplateSelection habit limit. Adjust or continue.';
  }
  return null;
}

String? windowsValidationError(List<SelectedHabit> habits) {
  final missing = habits.where((habit) => habit.windows.isEmpty).toList();
  if (missing.isEmpty) {
    return null;
  }
  if (missing.length == 1) {
    return 'Add a time window for ${missing.single.name}.';
  }
  return 'Add at least one time window to each selected habit.';
}
