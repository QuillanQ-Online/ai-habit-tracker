import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() {
  return integrationDriver(
    onScreenshot: (
      String screenshotName,
      List<int> screenshotBytes, [
      Map<String, Object?>? args,
    ]) async {
      final directory = Directory('build/integration_test_screenshots');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final file = File('${directory.path}/$screenshotName.png');
      await file.writeAsBytes(screenshotBytes);
      return true;
    },
  );
}
