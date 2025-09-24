import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';
import '../../shared/services/onboarding_service.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key, this.next});

  final String? next;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Nudge')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Onboarding flow placeholder. Complete to continue.',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await ref.read(onboardingServiceProvider).completeOnboarding();
                final destination = next ?? RoutePaths.today;
                if (!context.mounted) return;
                context.go(destination);
              },
              child: const Text('Finish Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}
