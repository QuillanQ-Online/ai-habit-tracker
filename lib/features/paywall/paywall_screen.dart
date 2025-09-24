import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';
import '../../shared/services/entitlements_service.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key, this.next});

  final String? next;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Go Pro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Unlock pro features by upgrading.'),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await ref.read(entitlementsServiceProvider).grantPro();
                final destination = next ?? RoutePaths.today;
                if (!context.mounted) return;
                context.go(destination);
              },
              child: const Text('Upgrade Now'),
            ),
          ],
        ),
      ),
    );
  }
}
