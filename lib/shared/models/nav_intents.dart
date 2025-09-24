import 'package:equatable/equatable.dart';

/// Represents an external navigation request parsed from deep links or
/// notification payloads. Additional intent types should extend this sealed
/// hierarchy.
sealed class NavIntent extends Equatable {
  const NavIntent();
}

class OpenHabitIntent extends NavIntent {
  const OpenHabitIntent(this.habitId);

  final String habitId;

  @override
  List<Object?> get props => [habitId];
}

class OpenPaywallIntent extends NavIntent {
  const OpenPaywallIntent(this.nextLocation);

  final String? nextLocation;

  @override
  List<Object?> get props => [nextLocation];
}

class OpenTodayIntent extends NavIntent {
  const OpenTodayIntent();

  @override
  List<Object?> get props => const [];
}

class PerformCompleteIntent extends NavIntent {
  const PerformCompleteIntent(this.habitId);

  final String habitId;

  @override
  List<Object?> get props => [habitId];
}

class UnknownIntent extends NavIntent {
  const UnknownIntent();

  @override
  List<Object?> get props => const [];
}
