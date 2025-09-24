import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routing/app_router.dart';
import 'routing/deep_link_handler.dart';
import 'routing/route_paths.dart';
import 'shared/services/nav_state_store.dart';
import 'shared/utils/snackbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final navStateStore = NavStateStore();
  final selectedTab = await navStateStore.readSelectedTab() ?? AppTab.today;
  final tabLocations = await navStateStore.readTabTopLocations();
  final initialConfig = InitialNavConfiguration(
    selectedTab: selectedTab,
    tabLocations: tabLocations,
  );

  runApp(
    ProviderScope(
      overrides: [
        navStateStoreProvider.overrideWithValue(navStateStore),
        initialNavConfigProvider.overrideWithValue(initialConfig),
      ],
      child: const NudgeApp(),
    ),
  );
}

class NudgeApp extends ConsumerWidget {
  const NudgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Nudge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: router,
    );
  }
}

/// Example hook for handling an external notification or widget intent.
Future<void> handleExternalIntent(Uri uri, WidgetRef ref) async {
  final intent = DeepLinkHandler.parse(uri);
  final router = ref.read(goRouterProvider);
  final snackBar = ref.read(snackBarServiceProvider);
  await NavIntentExecutor.execute(intent, router, snackBarService: snackBar);
}
