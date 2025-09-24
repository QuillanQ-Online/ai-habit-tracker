import 'package:flutter/material.dart';

import '../../../shared/widgets/step_scaffold.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.onGetStarted,
    required this.onMaybeLater,
  });

  final int stepIndex;
  final int totalSteps;
  final VoidCallback onGetStarted;
  final VoidCallback onMaybeLater;

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      stepIndex: stepIndex,
      totalSteps: totalSteps,
      title: 'Stay on track with gentle nudges',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Nudge helps you build meaningful routines with privacy-first reminders and insights that respect your pace.',
          ),
          SizedBox(height: 16),
          Text('We\'ll start with a couple of quick questions to tailor your plan.'),
        ],
      ),
      onPrimaryPressed: onGetStarted,
      primaryLabel: 'Get started',
      onBack: null,
      tertiaryLabel: 'Maybe later',
      onTertiaryPressed: onMaybeLater,
    );
  }
}
