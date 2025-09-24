import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routing/route_paths.dart';

/// Simple in-memory navigation state store used to model state restoration.
///
/// Replace with a persistence-backed implementation (e.g. `SharedPreferences`)
/// when wiring to production. The async APIs are intentionally retained so the
/// swap remains seamless.
class NavStateStore {
  AppTab? _selectedTab;
  final Map<AppTab, String> _tabTopLocations = {};
  String? _habitDraft;
  final Map<String, String> _habitEditDrafts = {};

  Future<void> writeSelectedTab(AppTab tab) async {
    _selectedTab = tab;
  }

  Future<AppTab?> readSelectedTab() async {
    return _selectedTab;
  }

  Future<void> writeTabTopLocation({
    required AppTab tab,
    required String location,
  }) async {
    _tabTopLocations[tab] = location;
  }

  Future<Map<AppTab, String>> readTabTopLocations() async {
    return Map<AppTab, String>.from(_tabTopLocations);
  }

  Future<void> writeHabitNewDraft(String json) async {
    _habitDraft = json;
  }

  Future<String?> readHabitNewDraft() async {
    return _habitDraft;
  }

  Future<void> clearHabitNewDraft() async {
    _habitDraft = null;
  }

  Future<void> writeHabitEditDraft({
    required String habitId,
    required String json,
  }) async {
    _habitEditDrafts[habitId] = json;
  }

  Future<String?> readHabitEditDraft(String habitId) async {
    return _habitEditDrafts[habitId];
  }

  Future<void> clearHabitEditDraft(String habitId) async {
    _habitEditDrafts.remove(habitId);
  }
}

final navStateStoreProvider = Provider<NavStateStore>((ref) {
  // TODO: swap to persistence-backed store.
  return NavStateStore();
});
