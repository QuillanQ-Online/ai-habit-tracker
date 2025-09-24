import 'package:flutter_test/flutter_test.dart';

import 'package:ai_habit_tracker/routing/route_guards.dart';
import 'package:ai_habit_tracker/shared/services/entitlements_service.dart';
import 'package:ai_habit_tracker/shared/services/onboarding_service.dart';

void main() {
  group('onboardingRedirect', () {
    test('redirects to onboarding when incomplete', () async {
      final service = OnboardingService();
      expect(
        await onboardingRedirect(
          onboardingService: service,
          attemptedLocation: '/today',
        ),
        '/onboarding?next=%2Ftoday',
      );
    });

    test('allows navigation when already complete', () async {
      final service = OnboardingService();
      await service.completeOnboarding();
      expect(
        await onboardingRedirect(
          onboardingService: service,
          attemptedLocation: '/today',
        ),
        isNull,
      );
    });
  });

  group('proRedirect', () {
    test('redirects to paywall when user is not pro', () async {
      final service = EntitlementsService();
      expect(
        await proRedirect(
          entitlementsService: service,
          attemptedLocation: '/habit/123/edit',
        ),
        '/paywall?next=%2Fhabit%2F123%2Fedit',
      );
    });

    test('allows navigation for pro users', () async {
      final service = EntitlementsService();
      await service.grantPro();
      expect(
        await proRedirect(
          entitlementsService: service,
          attemptedLocation: '/habit/123/edit',
        ),
        isNull,
      );
    });
  });
}
