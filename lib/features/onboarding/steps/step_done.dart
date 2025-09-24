import 'package:flutter/material.dart';

import '../../../shared/widgets/step_scaffold.dart';

class DoneStep extends StatelessWidget {
  const DoneStep({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.onFinish,
  });

  final int stepIndex;
  final int totalSteps;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      stepIndex: stepIndex,
      totalSteps: totalSteps,
      title: 'All set!',
      onPrimaryPressed: onFinish,
      primaryLabel: 'Let\'s go',
      onBack: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          const Icon(Icons.verified_rounded, size: 72, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Your plan is ready. We\'ll take you to Today to start acting on it.',
          ),
        ],
      ),
    );
  }
}
