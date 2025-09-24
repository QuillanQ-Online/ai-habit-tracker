import 'package:flutter/widgets.dart';

import '../routing/route_paths.dart';

typedef RouteEnterCallback = void Function(
  String? routeName,
  Map<String, String> params,
);
typedef RouteRedirectCallback = void Function(
  String from,
  String to,
  String reason,
);
typedef TabSwitchCallback = void Function(AppTab from, AppTab to);

/// Lightweight observer for navigation telemetry. Hooks into go_router's
/// observer list and shell tab switching to notify analytics or debugging tools.
class AppNavigationObserver extends NavigatorObserver {
  AppNavigationObserver({
    this.onRouteEnter,
    this.onRouteRedirect,
    this.onTabSwitch,
  });

  final RouteEnterCallback? onRouteEnter;
  final RouteRedirectCallback? onRouteRedirect;
  final TabSwitchCallback? onTabSwitch;

  void reportRedirect({
    required String from,
    required String to,
    required String reason,
  }) {
    onRouteRedirect?.call(from, to, reason);
  }

  void reportTabSwitch({
    required AppTab from,
    required AppTab to,
  }) {
    onTabSwitch?.call(from, to);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final settings = route.settings;
    onRouteEnter?.call(settings.name, settings.arguments is Map<String, String>
        ? settings.arguments! as Map<String, String>
        : const {});
  }
}
