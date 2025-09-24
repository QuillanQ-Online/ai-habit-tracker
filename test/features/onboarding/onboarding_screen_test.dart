import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_habit_tracker/features/onboarding/onboarding_controller.dart';
import 'package:ai_habit_tracker/features/onboarding/onboarding_screen.dart';
import 'package:ai_habit_tracker/features/onboarding/onboarding_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingScreen', () {
    testWidgets('first run completes and navigates to today', (tester) async {
      final storage = OnboardingStorage(store: InMemoryKeyValueStore());
      final router = _buildRouter('/');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [onboardingStorageProvider.overrideWithValue(storage)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Looks good'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable notifications'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Let's go"));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('today-screen')), findsOneWidget);
    });

    testWidgets('resume restores windows step', (tester) async {
      final storage = OnboardingStorage(store: InMemoryKeyValueStore());

      Future<void> runFlow(GoRouter router) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [onboardingStorageProvider.overrideWithValue(storage)],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();
      }

      var router = _buildRouter('/');
      await runFlow(router);

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Drink Water'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('When should we nudge you?'), findsOneWidget);

      // Simulate process death by rebuilding with the same storage.
      router = _buildRouter('/');
      await runFlow(router);
      await tester.pumpAndSettle();

      expect(find.text('When should we nudge you?'), findsOneWidget);
    });

    testWidgets('next route parameter respected', (tester) async {
      final storage = OnboardingStorage(store: InMemoryKeyValueStore());
      final router = _buildRouter('/?next=%2Fhabit%2Fnew');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [onboardingStorageProvider.overrideWithValue(storage)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Looks good'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enable notifications'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Let's go"));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('habit-new-screen')), findsOneWidget);
    });
  });
}

GoRouter _buildRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return OnboardingScreen(next: state.uri.queryParameters['next']);
        },
      ),
      GoRoute(
        path: '/today',
        builder: (context, state) => const Placeholder(key: ValueKey('today-screen')),
      ),
      GoRoute(
        path: '/habit/new',
        builder: (context, state) => const Placeholder(key: ValueKey('habit-new-screen')),
      ),
    ],
  );
}
