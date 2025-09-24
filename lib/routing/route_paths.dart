import 'package:flutter/foundation.dart';

/// Centralized definitions of route names and helpers for building locations.
/// Keeping the strings in one place reduces typos and keeps deep link parsing
/// consistent with navigation helpers.
@immutable
class RoutePaths {
  const RoutePaths._();

  // Shell tabs
  static const today = '/today';
  static const plan = '/plan';
  static const insights = '/insights';
  static const settings = '/settings';

  // Standalone flows
  static const onboarding = '/onboarding';
  static const habitNew = '/habit/new';
  static const habitDetail = '/habit/:id';
  static const habitEdit = '/habit/:id/edit';
  static const insightsDetail = '/insights/detail';
  static const paywall = '/paywall';

  // Route names used by go_router for analytics/telemetry.
  static const shell = 'app-shell';
  static const todayName = 'today';
  static const planName = 'plan';
  static const insightsName = 'insights';
  static const settingsName = 'settings';
  static const onboardingName = 'onboarding';
  static const habitNewName = 'habit-new';
  static const habitDetailName = 'habit-detail';
  static const habitEditName = 'habit-edit';
  static const insightsDetailName = 'insights-detail';
  static const paywallName = 'paywall';

  /// Location helper for habit detail.
  static String habitDetailPath(String habitId) => '/habit/$habitId';

  /// Location helper for habit edit.
  static String habitEditPath(String habitId) => '/habit/$habitId/edit';

  /// Location helper for onboarding with an optional next destination.
  static String onboardingPath({String? next}) {
    if (next == null || next.isEmpty) {
      return onboarding;
    }
    return '$onboarding?next=${Uri.encodeComponent(next)}';
  }

  /// Location helper for the paywall with an optional continuation target.
  static String paywallPath({String? next}) {
    if (next == null || next.isEmpty) {
      return paywall;
    }
    return '$paywall?next=${Uri.encodeComponent(next)}';
  }

  /// Location helper for the insights detail screen with optional filters.
  static String insightsDetailPath({
    required String metric,
    required String range,
    String? habitId,
  }) {
    final params = <String, String>{
      'metric': metric,
      'range': range,
      if (habitId != null) 'habitId': habitId,
    };
    final query = params.entries
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
        .join('&');
    return '$insightsDetail?$query';
  }
}

/// Indexes for the four tabs surfaced in the shell scaffold. Using an enum
/// provides type safety when reading/writing the persisted tab state.
enum AppTab { today, plan, insights, settings }

extension AppTabExtension on AppTab {
  int get index {
    switch (this) {
      case AppTab.today:
        return 0;
      case AppTab.plan:
        return 1;
      case AppTab.insights:
        return 2;
      case AppTab.settings:
        return 3;
    }
  }

  static AppTab fromIndex(int index) {
    if (index < 0 || index >= AppTab.values.length) {
      return AppTab.today;
    }
    return AppTab.values[index];
  }
}
