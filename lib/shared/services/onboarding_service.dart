import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service responsible for tracking onboarding completion status.
///
/// In production this would delegate to persistent storage. For now we keep the
/// completion flag in memory and expose async APIs that mirror an eventual
/// implementation.
class OnboardingService extends ChangeNotifier {
  bool _isComplete = false;

  bool get isCompleteSync => _isComplete;

  Future<bool> isComplete() async {
    return _isComplete;
  }

  Future<void> completeOnboarding() async {
    _isComplete = true;
    notifyListeners();
  }

  /// Resets onboarding completion. Useful for manual testing.
  Future<void> reset() async {
    _isComplete = false;
    notifyListeners();
  }
}

final onboardingServiceProvider = ChangeNotifierProvider<OnboardingService>((ref) {
  // TODO: wire to persistent storage implementation.
  return OnboardingService();
});
