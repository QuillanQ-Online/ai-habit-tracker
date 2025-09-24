import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';
import '../../shared/services/nav_state_store.dart';

class HabitNewScreen extends ConsumerStatefulWidget {
  const HabitNewScreen({super.key});

  @override
  ConsumerState<HabitNewScreen> createState() => _HabitNewScreenState();
}

class _HabitNewScreenState extends ConsumerState<HabitNewScreen> {
  late final TextEditingController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    Future.microtask(() async {
      final draft = await ref.read(navStateStoreProvider).readHabitNewDraft();
      if (draft != null) {
        _controller.text = draft;
      }
      if (mounted) {
        setState(() => _loading = false);
      }
    });
  }

  @override
  void dispose() {
    ref.read(navStateStoreProvider).writeHabitNewDraft(_controller.text);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('New Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Habit Name'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await ref.read(navStateStoreProvider).clearHabitNewDraft();
                // TODO: Save habit to backend and obtain an ID.
                if (!context.mounted) return;
                context.go(RoutePaths.habitDetailPath('new-habit'));
              },
              child: const Text('Create Habit'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(navStateStoreProvider)
                    .writeHabitNewDraft(_controller.text);
                context.go(RoutePaths.today);
              },
              child: const Text('Save Draft & Exit'),
            ),
          ],
        ),
      ),
    );
  }
}
