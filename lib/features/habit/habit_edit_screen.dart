import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';
import '../../shared/services/nav_state_store.dart';

class HabitEditScreen extends ConsumerStatefulWidget {
  const HabitEditScreen({super.key, required this.habitId});

  final String habitId;

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  late final TextEditingController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    Future.microtask(() async {
      final draft =
          await ref.read(navStateStoreProvider).readHabitEditDraft(widget.habitId);
      if (draft != null) {
        _controller.text = draft;
      } else {
        _controller.text = 'Existing habit ${widget.habitId}';
      }
      if (mounted) {
        setState(() => _loading = false);
      }
    });
  }

  @override
  void dispose() {
    ref
        .read(navStateStoreProvider)
        .writeHabitEditDraft(habitId: widget.habitId, json: _controller.text);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.habitId}')),
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
                await ref.read(navStateStoreProvider).clearHabitEditDraft(widget.habitId);
                // TODO: Persist changes to backend.
                if (!context.mounted) return;
                context.go(RoutePaths.habitDetailPath(widget.habitId));
              },
              child: const Text('Save Changes'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(navStateStoreProvider)
                    .writeHabitEditDraft(
                      habitId: widget.habitId,
                      json: _controller.text,
                    );
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
