import 'package:flutter/material.dart';

import '../../../shared/widgets/step_scaffold.dart';

class NotificationsPermissionStep extends StatelessWidget {
  const NotificationsPermissionStep({
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
      title: 'Stay accountable with gentle reminders',
      onPrimaryPressed: onContinue,
      primaryLabel: 'Continue',
      onBack: onBack,
      secondaryLabel: 'Back',
      tertiaryLabel: 'Fix later',
      onTertiaryPressed: onSkip,
      isPrimaryEnabled: status != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enable notifications so we can nudge you at the right time. You\'re always in control and can change this later in Settings.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onEnable,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Enable notifications'),
          ),
          const SizedBox(height: 12),
          Text(
            status == null
                ? 'Status: not requested yet'
                : status == true
                ? 'Notifications granted ✅'
                : 'Notifications denied. You can enable them later.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
