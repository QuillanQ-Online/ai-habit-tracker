import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller used to show or hide a global banner. The implementation is a
/// placeholder for future travel mode functionality.
class GlobalBannerController extends ChangeNotifier {
  bool _isVisible = false;
  String? _message;

  bool get isVisible => _isVisible;
  String? get message => _message;

  void show(String message) {
    _isVisible = true;
    _message = message;
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    _message = null;
    notifyListeners();
  }
}

final globalBannerControllerProvider =
    ChangeNotifierProvider<GlobalBannerController>((ref) {
  return GlobalBannerController();
});

/// Hosts the banner at the top of the app without affecting navigator state.
class GlobalBannerHost extends ConsumerWidget {
  const GlobalBannerHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(globalBannerControllerProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.isVisible)
          Material(
            color: Colors.orange.shade200,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  controller.message ?? 'Travel mode active',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
