import 'package:flutter_test/flutter_test.dart';

import 'package:ai_habit_tracker/features/onboarding/onboarding_controller.dart';
import 'package:ai_habit_tracker/features/onboarding/onboarding_storage.dart';
import 'package:ai_habit_tracker/shared/models/habit_template.dart';
import 'package:ai_habit_tracker/shared/services/onboarding_service.dart';
import 'package:ai_habit_tracker/shared/services/telemetry_service.dart';

void main() {
  late OnboardingController controller;
  late OnboardingStorage storage;
  late OnboardingService service;

  setUp(() async {
    storage = OnboardingStorage(store: InMemoryKeyValueStore());
    service = OnboardingService();
    controller = OnboardingController(
      storage: storage,
      onboardingService: service,
      telemetry: TelemetryService(),
    );
    await controller.hydrate();
  });

  test('selecting templates toggles up to limit', () {
    controller.toggleTemplate(defaultHabitTemplates[0]);
    controller.toggleTemplate(defaultHabitTemplates[1]);
    controller.toggleTemplate(defaultHabitTemplates[2]);

    expect(controller.state.selectedHabits, hasLength(3));
    expect(controller.hasReachedTemplateLimit, isTrue);

    controller.toggleTemplate(defaultHabitTemplates[0]);
    expect(controller.state.selectedHabits, hasLength(2));
  });

  test('windows validation fails when habit has no window', () {
    controller.toggleTemplate(defaultHabitTemplates.first);
    final habitId = controller.state.selectedHabits.first.templateId;
    controller.updateHabitWindows(habitId, []);

    expect(controller.validateStep(OnboardingStepId.windows), isFalse);
    expect(controller.state.canProceedFromWindows, isFalse);
  });

  test('complete onboarding marks service and clears storage', () async {
    await controller.completeOnboarding();

    expect(controller.state.isComplete, isTrue);
    expect(service.isCompleteSync, isTrue);
    final restored = await storage.restore();
    expect(restored, isNull);
  });

  test('hydrate restores saved state', () async {
    controller.toggleTemplate(defaultHabitTemplates.first);
    controller.advanceStep();
    await controller.hydrate(nextRoute: '/today');

    expect(controller.state.nextRoute, '/today');
    expect(controller.state.stepIndex, equals(1));
  });
}
