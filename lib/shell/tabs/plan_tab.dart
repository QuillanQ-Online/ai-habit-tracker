import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';

class PlanTabScreen extends StatelessWidget {
  const PlanTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Plan upcoming routines.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.go(RoutePaths.habitNew),
            child: const Text('Add Planned Habit'),
          ),
        ],
      ),
    );
  }
}
