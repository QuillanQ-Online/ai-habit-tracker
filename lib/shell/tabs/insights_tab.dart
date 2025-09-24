import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';

class InsightsTabScreen extends StatelessWidget {
  const InsightsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Insights and analytics appear here.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.go(
              RoutePaths.insightsDetailPath(metric: 'streak', range: '7d'),
            ),
            child: const Text('Open Weekly Streak Insight'),
          ),
        ],
      ),
    );
  }
}
