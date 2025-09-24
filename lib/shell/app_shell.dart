import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routing/navigation_observer.dart';
import '../routing/route_paths.dart';
import '../routing/router_keys.dart';
import '../shared/services/nav_state_store.dart';
import '../shared/widgets/global_banner.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.observer,
    required this.initialTab,
  });

  final StatefulNavigationShell navigationShell;
  final AppNavigationObserver observer;
  final AppTab initialTab;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late int _currentIndex;

  AppTab get _currentTab => AppTabExtension.fromIndex(_currentIndex);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistTabState(_currentTab);
    });
  }

  Future<bool> _onWillPop() async {
    final branchNavigator = _navigatorForTab(_currentTab).currentState;
    if (branchNavigator != null && branchNavigator.canPop()) {
      branchNavigator.pop();
      return false;
    }

    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return false;
    }

    if (Platform.isAndroid) {
      await SystemNavigator.pop();
      return false;
    }

    return true;
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) {
      widget.navigationShell.goBranch(index, initialLocation: true);
      return;
    }
    final previous = _currentTab;
    final next = AppTabExtension.fromIndex(index);
    _persistTabState(previous);
    widget.navigationShell.goBranch(index);
    widget.observer.reportTabSwitch(from: previous, to: next);
    setState(() => _currentIndex = index);
    _persistTabState(next);
  }

  void _persistTabState(AppTab tab) {
    ref.read(navStateStoreProvider).writeSelectedTab(tab);
    final router = GoRouter.of(context);
    final location =
        router.routeInformationProvider.value.uri.toString();
    ref.read(navStateStoreProvider).writeTabTopLocation(
          tab: tab,
          location: location,
        );
  }

  GlobalKey<NavigatorState> _navigatorForTab(AppTab tab) {
    if (tab == AppTab.today) {
      return todayNavigatorKey;
    }
    if (tab == AppTab.plan) {
      return planNavigatorKey;
    }
    if (tab == AppTab.insights) {
      return insightsNavigatorKey;
    }
    return settingsNavigatorKey;
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    return GlobalBannerHost(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            return;
          }
          final shouldPop = await _onWillPop();
          if (!shouldPop) {
            return;
          }
          if (!context.mounted) {
            return;
          }
          Navigator.of(context).maybePop(result);
        },
        child: Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.today),
                label: 'Today',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Plan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights),
                label: 'Insights',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
