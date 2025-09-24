import 'dart:async';

import '../shared/services/entitlements_service.dart';
import '../shared/services/onboarding_service.dart';
import 'route_paths.dart';

/// Determines whether navigation should redirect to onboarding based on the
/// onboarding completion state.
Future<String?> onboardingRedirect({
  required OnboardingService onboardingService,
  required String attemptedLocation,
}) async {
  final isComplete = await onboardingService.isComplete();
  if (isComplete) {
    return null;
  }

  final onboardingBase = RoutePaths.onboarding;
  if (attemptedLocation.startsWith(onboardingBase)) {
    // Already heading to onboarding; allow it to proceed.
    return null;
  }

  final encoded = Uri.encodeComponent(attemptedLocation);
  return '$onboardingBase?next=$encoded';
}

/// Determines whether navigation should redirect to the paywall when the user
/// lacks the required entitlement to open a pro-only destination.
Future<String?> proRedirect({
  required EntitlementsService entitlementsService,
  required String attemptedLocation,
}) async {
  final isPro = await entitlementsService.isPro();
  if (isPro) {
    return null;
  }

  final paywallBase = RoutePaths.paywall;
  if (attemptedLocation.startsWith(paywallBase)) {
    // Already moving toward the paywall; avoid redirect loops.
    return null;
  }

  final encoded = Uri.encodeComponent(attemptedLocation);
  return '$paywallBase?next=$encoded';
}
