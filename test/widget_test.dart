import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_habit_tracker/main.dart';
import 'package:ai_habit_tracker/routing/app_router.dart';
import 'package:ai_habit_tracker/shared/services/nav_state_store.dart';
import 'package:ai_habit_tracker/routing/route_paths.dart';

void main() {
  testWidgets('renders onboarding for new users', (tester) async {
    final navStore = NavStateStore();
    final initialConfig = InitialNavConfiguration(
      selectedTab: AppTab.today,
      tabLocations: {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          navStateStoreProvider.overrideWithValue(navStore),
          initialNavConfigProvider.overrideWithValue(initialConfig),
        ],
        child: const NudgeApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Stay on track with gentle nudges'), findsOneWidget);
  });
}
