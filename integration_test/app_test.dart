import 'package:ai_habit_tracker/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  testWidgets('displays the Today tab by default and captures a screenshot',
      (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.today), findsOneWidget);
    expect(find.text('Today'), findsWidgets);

    await binding.takeScreenshot('home-screen');
  });
}
