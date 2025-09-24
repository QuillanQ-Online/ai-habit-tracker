import 'package:go_router/go_router.dart';

import '../shared/models/nav_intents.dart';
import '../shared/utils/snackbar.dart';
import 'route_paths.dart';

/// Parses incoming URIs into strongly typed [NavIntent]s.
class DeepLinkHandler {
  static const _scheme = 'nudge';

  static NavIntent parse(Uri? uri) {
    if (uri == null) {
      return const UnknownIntent();
    }

    if (uri.scheme == _scheme) {
      return _parseAppScheme(uri);
    }

    // Allow direct HTTP(S) fallbacks by parsing the path segments.
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      return _parsePathSegments(uri.pathSegments, uri.queryParameters);
    }

    return const UnknownIntent();
  }

  static NavIntent _parseAppScheme(Uri uri) {
    final segments = <String>[];
    if (uri.host.isNotEmpty) {
      segments.add(uri.host);
    }
    segments.addAll(uri.pathSegments);
    return _parsePathSegments(segments, uri.queryParameters);
  }

  static NavIntent _parsePathSegments(
    List<String> segments,
    Map<String, String> queryParams,
  ) {
    if (segments.isEmpty) {
      return const UnknownIntent();
    }

    final first = segments.first;
    switch (first) {
      case 'habit':
        if (segments.length >= 2 && segments[1].isNotEmpty) {
          return OpenHabitIntent(segments[1]);
        }
        return const OpenTodayIntent();
      case 'paywall':
        final next = queryParams['next'];
        return OpenPaywallIntent(next);
      case 'today':
        return const OpenTodayIntent();
      case 'complete':
        if (segments.length >= 2 && segments[1].isNotEmpty) {
          return PerformCompleteIntent(segments[1]);
        }
        break;
    }

    return const UnknownIntent();
  }
}

/// Executes navigation intents using the global [GoRouter] instance.
class NavIntentExecutor {
  static Future<void> execute(
    NavIntent intent,
    GoRouter router, {
    required SnackBarService snackBarService,
    Future<void> Function(String habitId)? onPerformCompletion,
  }) async {
    switch (intent) {
      case OpenHabitIntent(:final habitId):
        router.go(RoutePaths.habitDetailPath(habitId));
        return;
      case OpenPaywallIntent(:final nextLocation):
        router.go(RoutePaths.paywallPath(next: nextLocation));
        return;
      case OpenTodayIntent():
        router.go(RoutePaths.today);
        return;
      case PerformCompleteIntent(:final habitId):
        if (onPerformCompletion != null) {
          await onPerformCompletion(habitId);
        }
        // In a real app we would check visibility; assume visible for now.
        snackBarService.showMessage('Marked habit $habitId complete');
        return;
      case UnknownIntent():
        snackBarService.showMessage('Opening Today');
        router.go(RoutePaths.today);
        return;
    }
  }
}
