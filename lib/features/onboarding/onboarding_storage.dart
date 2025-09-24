import 'dart:async';

import 'onboarding_state.dart';

/// Simple key-value storage abstraction for persisting onboarding progress.
class OnboardingStorage {
  OnboardingStorage({KeyValueStore? store}) : _store = store ?? InMemoryKeyValueStore();

  static const _storageKey = 'onboarding_state_v1';

  final KeyValueStore _store;

  Future<void> save(OnboardingState state) async {
    await _store.write(_storageKey, state.toJsonString());
  }

  Future<OnboardingState?> restore() async {
    final raw = await _store.read(_storageKey);
    return OnboardingState.tryDecode(raw);
  }

  Future<void> clear() async {
    await _store.delete(_storageKey);
  }
}

/// Minimal key-value store contract allowing swapping implementations later.
abstract class KeyValueStore {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);
}

/// In-memory fallback implementation used for unit testing and local dev.
class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _storage = {};

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    return _storage[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _storage[key] = value;
  }
}
