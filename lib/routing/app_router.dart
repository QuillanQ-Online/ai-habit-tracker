import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/habit/habit_detail_screen.dart';
import '../features/habit/habit_edit_screen.dart';
import '../features/habit/habit_new_screen.dart';
import '../features/insights/insights_detail_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/paywall/paywall_screen.dart';
import '../routing/router_keys.dart';
import '../shell/app_shell.dart';
import '../shell/tabs/insights_tab.dart';
import '../shell/tabs/plan_tab.dart';
import '../shell/tabs/settings_tab.dart';
import '../shell/tabs/today_tab.dart';
import '../shared/services/entitlements_service.dart';
import '../shared/services/nav_state_store.dart';
import '../shared/services/onboarding_service.dart';
import '../shared/utils/snackbar.dart';
import 'navigation_observer.dart';
import 'route_guards.dart';
import 'route_paths.dart';

class InitialNavConfiguration {
  InitialNavConfiguration({
    required this.selectedTab,
    required this.tabLocations,
  });

  final AppTab selectedTab;
  final Map<AppTab, String> tabLocations;
}

final initialNavConfigProvider = Provider<InitialNavConfiguration>((ref) {
  throw UnimplementedError('InitialNavConfiguration must be overridden.');
});

final appNavigationObserverProvider = Provider<AppNavigationObserver>((ref) {
  return AppNavigationObserver(
    onRouteEnter: (routeName, params) {
      // TODO: wire analytics event.
    },
    onRouteRedirect: (from, to, reason) {
      // TODO: send redirect telemetry.
    },
    onTabSwitch: (from, to) {
      // TODO: capture tab switch analytics.
    },
  );
});

String _defaultTabLocation(AppTab tab) {
  switch (tab) {
    case AppTab.today:
      return RoutePaths.today;
    case AppTab.plan:
      return RoutePaths.plan;
    case AppTab.insights:
      return RoutePaths.insights;
    case AppTab.settings:
      return RoutePaths.settings;
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final onboardingService = ref.watch(onboardingServiceProvider);
  final entitlementsService = ref.watch(entitlementsServiceProvider);
  final navStateStore = ref.watch(navStateStoreProvider);
  final snackBarService = ref.watch(snackBarServiceProvider);
  final observer = ref.watch(appNavigationObserverProvider);
  final initialConfig = ref.watch(initialNavConfigProvider);

  String initialLocationFor(AppTab tab) {
    return initialConfig.tabLocations[tab] ?? _defaultTabLocation(tab);
  }

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocationFor(initialConfig.selectedTab),
    observers: [observer],
    debugLogDiagnostics: false,
    restorationScopeId: 'nudge-router',
    refreshListenable:
        Listenable.merge([onboardingService, entitlementsService]),
    redirect: (context, state) async {
      final attempted = state.uri.toString();
      final onboardingResult = await onboardingRedirect(
        onboardingService: onboardingService,
        attemptedLocation: attempted,
      );
      if (onboardingResult != null) {
        observer.reportRedirect(
          from: attempted,
          to: onboardingResult,
          reason: 'onboarding',
        );
        return onboardingResult;
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final tab = initialConfig.selectedTab;
          return AppShell(
            navigationShell: navigationShell,
            observer: observer,
            initialTab: tab,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: todayNavigatorKey,
            initialLocation: initialLocationFor(AppTab.today),
            routes: [
              GoRoute(
                path: RoutePaths.today,
                name: RoutePaths.todayName,
                builder: (context, state) {
                  navStateStore.writeTabTopLocation(
                    tab: AppTab.today,
                    location: state.uri.toString(),
                  );
                  return const TodayTabScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: planNavigatorKey,
            initialLocation: initialLocationFor(AppTab.plan),
            routes: [
              GoRoute(
                path: RoutePaths.plan,
                name: RoutePaths.planName,
                builder: (context, state) {
                  navStateStore.writeTabTopLocation(
                    tab: AppTab.plan,
                    location: state.uri.toString(),
                  );
                  return const PlanTabScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: insightsNavigatorKey,
            initialLocation: initialLocationFor(AppTab.insights),
            routes: [
              GoRoute(
                path: RoutePaths.insights,
                name: RoutePaths.insightsName,
                builder: (context, state) {
                  navStateStore.writeTabTopLocation(
                    tab: AppTab.insights,
                    location: state.uri.toString(),
                  );
                  return const InsightsTabScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: settingsNavigatorKey,
            initialLocation: initialLocationFor(AppTab.settings),
            routes: [
              GoRoute(
                path: RoutePaths.settings,
                name: RoutePaths.settingsName,
                builder: (context, state) {
                  navStateStore.writeTabTopLocation(
                    tab: AppTab.settings,
                    location: state.uri.toString(),
                  );
                  return const SettingsTabScreen();
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.onboarding,
        name: RoutePaths.onboardingName,
        builder: (context, state) {
          return OnboardingScreen(next: state.uri.queryParameters['next']);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.habitNew,
        name: RoutePaths.habitNewName,
        builder: (context, state) => const HabitNewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.habitDetail,
        name: RoutePaths.habitDetailName,
        redirect: (context, state) {
          final habitId = state.pathParameters['id'];
          if (habitId == null || habitId.isEmpty) {
            snackBarService.showMessage('Habit not found. Returning to Today.');
            return RoutePaths.today;
          }
          return null;
        },
        builder: (context, state) {
          final habitId = state.pathParameters['id']!;
          return HabitDetailScreen(habitId: habitId);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.habitEdit,
        name: RoutePaths.habitEditName,
        redirect: (context, state) async {
          final habitId = state.pathParameters['id'];
          if (habitId == null || habitId.isEmpty) {
            snackBarService.showMessage('Habit not found. Returning to Today.');
            return RoutePaths.today;
          }
          final attempted = state.uri.toString();
          final proResult = await proRedirect(
            entitlementsService: entitlementsService,
            attemptedLocation: attempted,
          );
          if (proResult != null) {
            observer.reportRedirect(
              from: attempted,
              to: proResult,
              reason: 'pro-gate',
            );
            return proResult;
          }
          return null;
        },
        builder: (context, state) {
          final habitId = state.pathParameters['id']!;
          return HabitEditScreen(habitId: habitId);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.insightsDetail,
        name: RoutePaths.insightsDetailName,
        redirect: (context, state) async {
          final metric = state.uri.queryParameters['metric'];
          final range = state.uri.queryParameters['range'];
          if (metric == null || range == null) {
            snackBarService.showMessage('Insight unavailable. Showing Today.');
            return RoutePaths.today;
          }
          final attempted = state.uri.toString();
          final proResult = await proRedirect(
            entitlementsService: entitlementsService,
            attemptedLocation: attempted,
          );
          if (proResult != null) {
            observer.reportRedirect(
              from: attempted,
              to: proResult,
              reason: 'pro-gate',
            );
            return proResult;
          }
          return null;
        },
        builder: (context, state) {
          final metric = state.uri.queryParameters['metric']!;
          final range = state.uri.queryParameters['range']!;
          final habitId = state.uri.queryParameters['habitId'];
          return InsightsDetailScreen(
            metric: metric,
            range: range,
            habitId: habitId,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RoutePaths.paywall,
        name: RoutePaths.paywallName,
        builder: (context, state) {
          return PaywallScreen(next: state.uri.queryParameters['next']);
        },
      ),
    ],
  );
});
