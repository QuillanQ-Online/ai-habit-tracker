import 'package:flutter_test/flutter_test.dart';

import 'package:ai_habit_tracker/routing/deep_link_handler.dart';
import 'package:ai_habit_tracker/shared/models/nav_intents.dart';

void main() {
  test('parses habit deep link', () {
    final intent = DeepLinkHandler.parse(Uri.parse('nudge://habit/42'));
    expect(intent, isA<OpenHabitIntent>());
    expect((intent as OpenHabitIntent).habitId, '42');
  });

  test('falls back on invalid deep link', () {
    final intent = DeepLinkHandler.parse(Uri.parse('nudge://unknown'));
    expect(intent, isA<UnknownIntent>());
  });

  test('parses paywall deep link with next', () {
    final intent = DeepLinkHandler.parse(Uri.parse('nudge://paywall?next=%2Ftoday'));
    expect(intent, isA<OpenPaywallIntent>());
    expect((intent as OpenPaywallIntent).nextLocation, '/today');
  });
}
