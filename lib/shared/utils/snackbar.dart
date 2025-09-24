import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global key used to display snack bars from anywhere in the app.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Simplistic snack bar service to surface one-shot messages. Stubbing the
/// service allows tests to inject a fake implementation.
class SnackBarService {
  SnackBarService(this._messengerKey);

  final GlobalKey<ScaffoldMessengerState> _messengerKey;

  void showMessage(String message) {
    final messenger = _messengerKey.currentState;
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

final snackBarServiceProvider = Provider<SnackBarService>((ref) {
  // TODO: allow injecting mock messenger for widget tests.
  return SnackBarService(scaffoldMessengerKey);
});
