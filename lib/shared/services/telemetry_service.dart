import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub telemetry service capturing analytics events.
class TelemetryService {
  void logEvent(String name, [Map<String, Object?> parameters = const {}]) {
    // TODO: integrate with analytics backend.
  }
}

final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return TelemetryService();
});
