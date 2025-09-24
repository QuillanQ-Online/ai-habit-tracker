import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service that represents whether the current user has access to pro
/// functionality. The implementation would typically bridge to a purchases SDK
/// or server-side entitlement check.
class EntitlementsService extends ChangeNotifier {
  bool _isPro = false;

  bool get isProSync => _isPro;

  Future<bool> isPro() async {
    return _isPro;
  }

  Future<void> grantPro() async {
    _isPro = true;
    notifyListeners();
  }

  Future<void> revokePro() async {
    _isPro = false;
    notifyListeners();
  }
}

final entitlementsServiceProvider = ChangeNotifierProvider<EntitlementsService>((ref) {
  // TODO: bridge to real purchase flow implementation.
  return EntitlementsService();
});
