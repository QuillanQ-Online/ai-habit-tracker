import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';
import '../../shared/models/habit_template.dart';
import '../../shared/utils/validation.dart';
import 'onboarding_controller.dart';
import 'onboarding_state.dart';
import 'steps/step_done.dart';
import 'steps/step_permissions_health.dart';
import 'steps/step_permissions_notifications.dart';
import 'steps/step_review.dart';
import 'steps/step_templates.dart';
import 'steps/step_welcome.dart';
import 'steps/step_windows.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.next});

  final String? next;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrate();
    });
  }

  Future<void> _hydrate() async {
    final controller = ref.read(onboardingControllerProvider.notifier);
    await controller.hydrate(nextRoute: widget.next);
    setState(() {
      _hydrated = true;
    });
    controller.recordStepViewed(controller.currentStep);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OnboardingState>(onboardingControllerProvider, (previous, next) {
      if (previous?.stepIndex != next.stepIndex || previous == null) {
        final controller = ref.read(onboardingControllerProvider.notifier);
        controller.recordStepViewed(controller.currentStep);
      }
    });

    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final totalSteps = controller.activeSteps.length;
    final stepIndex = state.stepIndex;
    final currentStep = controller.currentStep;

    if (!_hydrated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final latestState = ref.read(onboardingControllerProvider);
        await _handleBackNavigation(controller, latestState);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(stepIndex == 0 ? Icons.close : Icons.arrow_back),
            onPressed: () async {
              final latestState = ref.read(onboardingControllerProvider);
              await _handleBackNavigation(controller, latestState);
            },
          ),
          title: const Text('Getting started'),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildStep(
            context,
            state,
            controller,
            currentStep,
            stepIndex,
            totalSteps,
          ),
        ),
      ),
    );
  }

  Future<void> _handleBackNavigation(
    OnboardingController controller,
    OnboardingState state,
  ) async {
    if (state.stepIndex == 0) {
      final router = GoRouter.of(context);
      final exit = await _confirmExit(context);
      if (exit && mounted) {
        router.go(RoutePaths.today);
      }
      return;
    }
    controller.retreatStep();
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave onboarding?'),
          content: const Text('You can always resume from Settings later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Widget _buildStep(
    BuildContext context,
    OnboardingState state,
    OnboardingController controller,
    OnboardingStepId step,
    int stepIndex,
    int totalSteps,
  ) {
    switch (step) {
      case OnboardingStepId.welcome:
        return WelcomeStep(
          key: const ValueKey('welcome'),
          stepIndex: stepIndex,
          totalSteps: totalSteps,
          onGetStarted: controller.advanceStep,
          onMaybeLater: () {
            controller.skipTemplates();
            controller.goToStep(OnboardingStepId.notifications);
          },
        );
      case OnboardingStepId.templates:
        return TemplatePickerStep(
          key: const ValueKey('templates'),
          stepIndex: stepIndex,
          totalSteps: totalSteps,
          templates: defaultHabitTemplates,
          selectedHabits: state.selectedHabits,
          onToggle: controller.toggleTemplate,
          onContinue: () {
            if (!controller.validateStep(OnboardingStepId.templates)) {
              _showError(
                context,
                templateSelectionError(state.selectedHabits.length),
              );
              return;
            }
            controller.advanceStep();
          },
          onBack: controller.retreatStep,
          onSkip: () {
            controller.skipTemplates();
            controller.advanceStep();
          },
        );
      case OnboardingStepId.windows:
        return TimeWindowsStep(
          key: const ValueKey('windows'),
          stepIndex: stepIndex,
          totalSteps: totalSteps,
          habits: state.selectedHabits,
          onBack: controller.retreatStep,
          onContinue: () {
            if (!controller.validateStep(OnboardingStepId.windows)) {
              _showError(context, windowsValidationError(state.selectedHabits));
              return;
            }
            controller.advanceStep();
          },
          onUpdateWindows: controller.updateHabitWindows,
          onAddCustomTime: (dialogContext) => _pickTime(dialogContext),
        );
      case OnboardingStepId.review:
        return ReviewStep(
          key: const ValueKey('review'),
          stepIndex: stepIndex,
          totalSteps: totalSteps,
          habits: state.selectedHabits,
          onBack: controller.retreatStep,
          onConfirm: () {
            if (!controller.validateStep(OnboardingStepId.review)) {
              _showError(context, windowsValidationError(state.selectedHabits));
              return;
            }
            controller.advanceStep();
          },
          onUpdateTarget: controller.updateHabitTarget,
          onUpdateWindows: controller.updateHabitWindows,
        );
      case OnboardingStepId.notifications:
        return NotificationsPermissionStep(
          key: const ValueKey('notifications'),
          stepIndex: stepIndex,
          totalSteps: totalSteps,
          status: state.notificationsGranted,
          onBack: controller.retreatStep,
          onContinue: () {
            if (!controller.validateStep(OnboardingStepId.notifications)) {
              _showError(context, 'Choose enable or skip to continue.');
              return;
            }
            controller.advanceStep();
          },
          onEnable: () async {
            final granted = await _showPermissionPrompt(
              context,
              title: 'Allow notifications?',
              message:
                  'We\'ll only send relevant nudges and you can adjust at any time.',
              confirmLabel: 'Allow',
            );
            if (granted != null) {
              controller.setNotificationsResult(granted);
            }
          },
          onSkip: () {
            controller.setNotificationsResult(false);
            controller.advanceStep();
            _showError(
              context,
              'Notifications can be enabled later from Settings.',
            );
          },
        );
      case OnboardingStepId.health:
        return HealthPermissionStep(
          key: const ValueKey('health'),
          stepIndex: stepIndex,
          totalSteps: totalSteps,
          status: state.healthGranted,
          onBack: controller.retreatStep,
          onContinue: () {
            if (!controller.validateStep(OnboardingStepId.health)) {
              _showError(context, 'Choose enable or skip to continue.');
              return;
            }
            controller.advanceStep();
          },
          onEnable: () async {
            final granted = await _showPermissionPrompt(
              context,
              title: 'Connect Health?',
              message:
                  'Read-only access lets us mark workouts, steps, mindfulness, and sleep as done automatically.',
              confirmLabel: 'Connect',
            );
            if (granted != null) {
              controller.setHealthResult(granted);
            }
          },
          onSkip: () {
            controller.setHealthResult(false);
            controller.advanceStep();
          },
        );
      case OnboardingStepId.done:
        return DoneStep(
          key: const ValueKey('done'),
          stepIndex: stepIndex,
          totalSteps: totalSteps,
          onFinish: () async {
            final router = GoRouter.of(context);
            final destination =
                ref.read(onboardingControllerProvider).nextRoute ??
                RoutePaths.today;
            await controller.completeOnboarding();
            router.go(destination);
          },
        );
    }
  }

  Future<TimeOfDay?> _pickTime(BuildContext context) {
    final now = TimeOfDay.now();
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: (now.minute ~/ 5) * 5),
    );
  }

  Future<bool?> _showPermissionPrompt(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  void _showError(BuildContext context, String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
