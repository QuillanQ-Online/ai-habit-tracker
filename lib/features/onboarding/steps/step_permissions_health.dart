import 'package:flutter/material.dart';

import '../../../shared/widgets/step_scaffold.dart';

class HealthPermissionStep extends StatelessWidget {
  const HealthPermissionStep({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.status,
    required this.onBack,
    required this.onContinue,
    required this.onEnable,
    required this.onSkip,
  });

  final int stepIndex;
  final int totalSteps;
  final bool? status;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final Future<void> Function() onEnable;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StepScaffold(
      stepIndex: stepIndex,
      totalSteps: totalSteps,
      title: 'Connect your health data (optional)',
      onPrimaryPressed: onContinue,
      primaryLabel: 'Continue',
      onBack: onBack,
      secondaryLabel: 'Back',
      tertiaryLabel: 'Skip for now',
      onTertiaryPressed: onSkip,
      isPrimaryEnabled: status != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import mindful minutes, steps, and workouts to auto-complete habits. We only request read-only access.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onEnable,
            icon: const Icon(Icons.favorite_outline),
            label: const Text('Enable health sync'),
          ),
          const SizedBox(height: 12),
          Text(
            status == null
                ? 'Status: not requested yet'
                : status == true
                ? 'Health access granted ✅'
                : 'Health access declined. You can reconnect later.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
