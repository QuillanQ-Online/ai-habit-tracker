import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_habit_tracker/features/habit/habit_new_screen.dart';
import 'package:ai_habit_tracker/shared/services/nav_state_store.dart';

class TestNavStateStore extends NavStateStore {
  int draftWrites = 0;
  bool draftCleared = false;

  @override
  Future<void> writeHabitNewDraft(String json) async {
    draftWrites++;
    await super.writeHabitNewDraft(json);
  }

  @override
  Future<void> clearHabitNewDraft() async {
    draftCleared = true;
    await super.clearHabitNewDraft();
  }
}

void main() {
  testWidgets('clearing the habit draft skips autosave on dispose', (tester) async {
    final store = TestNavStateStore();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HabitNewScreen(),
          routes: [
            GoRoute(
              path: 'habit/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? 'unknown';
                return Scaffold(
                  appBar: AppBar(title: Text('Habit $id')),
                  body: Center(child: Text('Habit detail for $id')),
                );
              },
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          navStateStoreProvider.overrideWithValue(store),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Morning Run');

    await tester.tap(find.text('Create Habit'));
    await tester.pumpAndSettle();

    expect(store.draftCleared, isTrue);
    expect(store.draftWrites, 0);
    expect(await store.readHabitNewDraft(), isNull);
  });
}
