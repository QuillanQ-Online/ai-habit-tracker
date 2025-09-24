import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Habit $habitId')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Details for habit: $habitId'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                context.go(RoutePaths.habitEditPath(habitId));
              },
              child: const Text('Edit Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
