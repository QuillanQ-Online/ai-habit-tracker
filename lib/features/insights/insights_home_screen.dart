import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';

class InsightsHomeScreen extends StatelessWidget {
  const InsightsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('High level analytics overview.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.go(
              RoutePaths.insightsDetailPath(metric: 'focus', range: '30d'),
            ),
            child: const Text('Open 30 Day Focus Insight'),
          ),
        ],
      ),
    );
  }
}
