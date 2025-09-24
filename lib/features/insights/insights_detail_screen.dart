import 'package:flutter/material.dart';

class InsightsDetailScreen extends StatelessWidget {
  const InsightsDetailScreen({
    super.key,
    required this.metric,
    required this.range,
    this.habitId,
  });

  final String metric;
  final String range;
  final String? habitId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insight Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metric: $metric'),
            Text('Range: $range'),
            if (habitId != null) Text('Habit: $habitId'),
          ],
        ),
      ),
    );
  }
}
