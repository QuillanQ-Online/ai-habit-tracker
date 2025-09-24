import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';
import '../../shared/services/entitlements_service.dart';
import '../../shared/services/onboarding_service.dart';

class SettingsTabScreen extends ConsumerWidget {
  const SettingsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingServiceProvider);
    final entitlements = ref.watch(entitlementsServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Onboarding Complete'),
            value: onboarding.isCompleteSync,
            onChanged: (value) async {
              if (value) {
                await onboarding.completeOnboarding();
              } else {
                await onboarding.reset();
              }
            },
          ),
          SwitchListTile(
            title: const Text('Pro Access'),
            value: entitlements.isProSync,
            onChanged: (value) async {
              if (value) {
                await entitlements.grantPro();
              } else {
                await entitlements.revokePro();
              }
            },
          ),
          const Divider(),
          TextButton(
            onPressed: () {
              // Demonstrates opening the paywall manually.
              context.go(RoutePaths.paywall);
            },
            child: const Text('View Paywall'),
          ),
        ],
      ),
    );
  }
}
