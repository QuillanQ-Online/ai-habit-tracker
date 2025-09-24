import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';

class TodayTabScreen extends StatelessWidget {
  const TodayTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Today overview goes here.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.go(RoutePaths.habitNew),
            child: const Text('Create Habit'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.go(RoutePaths.habitDetailPath('demo')),
            child: const Text('Open Sample Habit'),
          ),
        ],
      ),
    );
  }
}
