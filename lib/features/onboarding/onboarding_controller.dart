import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/habit_template.dart';
import '../../shared/services/onboarding_service.dart';
import '../../shared/services/telemetry_service.dart';
import 'onboarding_state.dart';
import 'onboarding_storage.dart';

final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  return OnboardingStorage();
});

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final storage = ref.watch(onboardingStorageProvider);
  final service = ref.watch(onboardingServiceProvider);
  final telemetry = ref.watch(telemetryServiceProvider);
  return OnboardingController(
    storage: storage,
    onboardingService: service,
    telemetry: telemetry,
  );
});

/// Ordered onboarding steps.
const _stepsWithHealth = [
  OnboardingStepId.welcome,
  OnboardingStepId.templates,
  OnboardingStepId.windows,
  OnboardingStepId.review,
  OnboardingStepId.notifications,
  OnboardingStepId.health,
  OnboardingStepId.done,
];

const _stepsWithoutHealth = [
  OnboardingStepId.welcome,
  OnboardingStepId.templates,
  OnboardingStepId.windows,
  OnboardingStepId.review,
  OnboardingStepId.notifications,
  OnboardingStepId.done,
];

enum OnboardingStepId {
  welcome,
  templates,
  windows,
  review,
  notifications,
  health,
  done,
}

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController({
    required OnboardingStorage storage,
    required OnboardingService onboardingService,
    required TelemetryService telemetry,
  })  : _storage = storage,
        _onboardingService = onboardingService,
        _telemetry = telemetry,
        super(OnboardingState.initial());

  final OnboardingStorage _storage;
  final OnboardingService _onboardingService;
  final TelemetryService _telemetry;

  List<OnboardingStepId> get activeSteps =>
      state.shouldRequestHealth ? _stepsWithHealth : _stepsWithoutHealth;

  OnboardingStepId get currentStep => activeSteps[state.stepIndex];

  bool get isLastStep => state.stepIndex >= activeSteps.length - 1;

  bool get hasReachedTemplateLimit => state.selectedHabits.length >= 3;

  OnboardingState _withClampedIndex(OnboardingState state) {
    final steps = state.shouldRequestHealth ? _stepsWithHealth : _stepsWithoutHealth;
    final maxIndex = steps.length - 1;
    final clamped = state.stepIndex.clamp(0, maxIndex);
    if (clamped != state.stepIndex) {
      state = state.copyWith(stepIndex: clamped);
    }
    return state;
  }

  Future<void> hydrate({String? nextRoute, bool shouldRequestHealth = true}) async {
    final restored = await _storage.restore();
    if (restored != null) {
      var nextState = restored.copyWith(
        nextRoute: nextRoute ?? restored.nextRoute,
        shouldRequestHealth: restored.shouldRequestHealth && shouldRequestHealth,
      );
      nextState = _withClampedIndex(nextState);
      state = nextState;
    } else {
      var nextState = OnboardingState.initial(
        nextRoute: nextRoute,
        shouldRequestHealth: shouldRequestHealth,
      );
      nextState = _withClampedIndex(nextState);
      state = nextState;
      await _persist();
    }
  }

  void updateNextRoute(String? nextRoute) {
    state = state.copyWith(nextRoute: nextRoute);
    unawaited(_persist());
  }

  void recordStepViewed(OnboardingStepId step) {
    _telemetry.logEvent('onboarding_step_viewed', {'step': step.name});
  }

  void toggleTemplate(HabitTemplate template) {
    final existingIndex = state.selectedHabits.indexWhere(
      (habit) => habit.templateId == template.id,
    );
    if (existingIndex >= 0) {
      final updated = [...state.selectedHabits]..removeAt(existingIndex);
      state = state.copyWith(selectedHabits: updated, templatesSkipped: updated.isEmpty ? state.templatesSkipped : false);
      _telemetry.logEvent('onboarding_template_selected', {
        'templateId': template.id,
        'selected': false,
      });
    } else {
      if (state.selectedHabits.length >= 3) {
        return;
      }
      final updated = [...state.selectedHabits, SelectedHabit.fromTemplate(template)];
      state = state.copyWith(selectedHabits: updated, templatesSkipped: false);
      _telemetry.logEvent('onboarding_template_selected', {
        'templateId': template.id,
        'selected': true,
      });
    }
    unawaited(_persist());
  }

  void skipTemplates() {
    state = state.copyWith(
      selectedHabits: const [],
      templatesSkipped: true,
    );
    unawaited(_persist());
  }

  void goToStep(OnboardingStepId step) {
    final index = activeSteps.indexOf(step);
    if (index == -1) {
      return;
    }
    state = state.copyWith(stepIndex: index);
    unawaited(_persist());
  }

  void updateHabitTarget(String templateId, int target) {
    final updated = state.selectedHabits.map((habit) {
      if (habit.templateId == templateId) {
        return habit.copyWith(target: target.clamp(1, 1000));
      }
      return habit;
    }).toList();
    state = state.copyWith(selectedHabits: updated);
    _telemetry.logEvent('onboarding_windows_saved', {
      'type': 'target_update',
      'templateId': templateId,
      'target': target,
    });
    unawaited(_persist());
  }

  void updateHabitWindows(String templateId, List<TimeWindowSelection> windows) {
    final updated = state.selectedHabits.map((habit) {
      if (habit.templateId == templateId) {
        return habit.copyWith(windows: windows);
      }
      return habit;
    }).toList();
    state = state.copyWith(selectedHabits: updated);
    _telemetry.logEvent('onboarding_windows_saved', {
      'type': 'window_update',
      'templateId': templateId,
      'windows': windows.map((window) => window.toJson()).toList(),
    });
    unawaited(_persist());
  }

  void setQuietHours(String templateId, QuietHours quietHours) {
    final updated = state.selectedHabits.map((habit) {
      if (habit.templateId == templateId) {
        return habit.copyWith(quietHours: quietHours);
      }
      return habit;
    }).toList();
    state = state.copyWith(selectedHabits: updated);
    unawaited(_persist());
  }

  void setNotificationsResult(bool granted) {
    state = state.copyWith(notificationsGranted: granted);
    _telemetry.logEvent('permission_request', {
      'type': 'notifications',
      'result': granted ? 'granted' : 'denied',
    });
    unawaited(_persist());
  }

  void setHealthResult(bool granted) {
    state = state.copyWith(healthGranted: granted);
    _telemetry.logEvent('permission_request', {
      'type': 'health',
      'result': granted ? 'granted' : 'denied',
    });
    unawaited(_persist());
  }

  void advanceStep() {
    final nextIndex = (state.stepIndex + 1).clamp(0, activeSteps.length - 1);
    state = _withClampedIndex(state.copyWith(stepIndex: nextIndex));
    unawaited(_persist());
  }

  void retreatStep() {
    final previousIndex = (state.stepIndex - 1).clamp(0, activeSteps.length - 1);
    state = _withClampedIndex(state.copyWith(stepIndex: previousIndex));
    unawaited(_persist());
  }

  bool validateStep(OnboardingStepId step) {
    switch (step) {
      case OnboardingStepId.welcome:
        return true;
      case OnboardingStepId.templates:
        return state.canProceedFromTemplates;
      case OnboardingStepId.windows:
        return state.canProceedFromWindows;
      case OnboardingStepId.review:
        return state.canProceedFromWindows;
      case OnboardingStepId.notifications:
        return state.notificationsGranted != null;
      case OnboardingStepId.health:
        return !state.shouldRequestHealth || state.healthGranted != null;
      case OnboardingStepId.done:
        return state.isComplete;
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isComplete: true);
    _telemetry.logEvent('onboarding_completed', {
      'count': state.selectedHabits.length,
    });
    await _persist();
    await _onboardingService.completeOnboarding();
    await _storage.clear();
  }

  Future<void> _persist() async {
    await _storage.save(state);
  }
}
