import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../shared/models/habit_template.dart';

/// Immutable state describing onboarding progress.
class OnboardingState extends Equatable {
  const OnboardingState({
    required this.stepIndex,
    required this.selectedHabits,
    required this.notificationsGranted,
    required this.healthGranted,
    required this.nextRoute,
    required this.isComplete,
    required this.shouldRequestHealth,
    required this.templatesSkipped,
  });

  factory OnboardingState.initial({
    String? nextRoute,
    bool shouldRequestHealth = true,
  }) {
    return OnboardingState(
      stepIndex: 0,
      selectedHabits: const [],
      notificationsGranted: null,
      healthGranted: null,
      nextRoute: nextRoute,
      isComplete: false,
      shouldRequestHealth: shouldRequestHealth,
      templatesSkipped: false,
    );
  }

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      stepIndex: json['stepIndex'] as int,
      selectedHabits: (json['selectedHabits'] as List<dynamic>)
          .map((raw) => SelectedHabit.fromJson(raw as Map<String, dynamic>))
          .toList(),
      notificationsGranted: json['notificationsGranted'] as bool?,
      healthGranted: json['healthGranted'] as bool?,
      nextRoute: json['nextRoute'] as String?,
      isComplete: json['isComplete'] as bool? ?? false,
      shouldRequestHealth: json['shouldRequestHealth'] as bool? ?? true,
      templatesSkipped: json['templatesSkipped'] as bool? ?? false,
    );
  }

  OnboardingState copyWith({
    int? stepIndex,
    List<SelectedHabit>? selectedHabits,
    bool? notificationsGranted,
    bool? healthGranted,
    String? nextRoute,
    bool? isComplete,
    bool? shouldRequestHealth,
    bool? templatesSkipped,
  }) {
    return OnboardingState(
      stepIndex: stepIndex ?? this.stepIndex,
      selectedHabits: selectedHabits ?? this.selectedHabits,
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      healthGranted: healthGranted ?? this.healthGranted,
      nextRoute: nextRoute ?? this.nextRoute,
      isComplete: isComplete ?? this.isComplete,
      shouldRequestHealth: shouldRequestHealth ?? this.shouldRequestHealth,
      templatesSkipped: templatesSkipped ?? this.templatesSkipped,
    );
  }

  final int stepIndex;
  final List<SelectedHabit> selectedHabits;
  final bool? notificationsGranted;
  final bool? healthGranted;
  final String? nextRoute;
  final bool isComplete;
  final bool shouldRequestHealth;
  final bool templatesSkipped;

  bool get hasSelectedTemplates => selectedHabits.isNotEmpty;

  bool get canProceedFromTemplates => selectedHabits.length <= 3;

  bool get canProceedFromWindows {
    if (selectedHabits.isEmpty) {
      return true;
    }
    return selectedHabits.every((habit) => habit.windows.isNotEmpty);
  }

  Map<String, dynamic> toJson() {
    return {
      'stepIndex': stepIndex,
      'selectedHabits': selectedHabits.map((habit) => habit.toJson()).toList(),
      'notificationsGranted': notificationsGranted,
      'healthGranted': healthGranted,
      'nextRoute': nextRoute,
      'isComplete': isComplete,
      'shouldRequestHealth': shouldRequestHealth,
      'templatesSkipped': templatesSkipped,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static OnboardingState? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return OnboardingState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  List<Object?> get props => [
        stepIndex,
        selectedHabits,
        notificationsGranted,
        healthGranted,
        nextRoute,
        isComplete,
        shouldRequestHealth,
        templatesSkipped,
      ];
}
