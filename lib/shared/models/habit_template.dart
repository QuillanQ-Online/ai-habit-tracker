import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Units supported for habit targets.
enum HabitUnit {
  boolean,
  count,
  minutes,
  milliliters,
  pages,
}

extension HabitUnitDisplay on HabitUnit {
  String get label {
    switch (this) {
      case HabitUnit.boolean:
        return 'times';
      case HabitUnit.count:
        return 'count';
      case HabitUnit.minutes:
        return 'minutes';
      case HabitUnit.milliliters:
        return 'ml';
      case HabitUnit.pages:
        return 'pages';
    }
  }

  String get analyticsValue {
    return name;
  }
}

/// Standard time windows offered to the user.
enum TimeWindowPreset {
  morning,
  afternoon,
  evening,
}

/// Represents a selected time window. Either a preset or a custom time of day.
class TimeWindowSelection extends Equatable {
  const TimeWindowSelection._({
    required this.type,
    this.preset,
    this.customTime,
  });

  factory TimeWindowSelection.preset(TimeWindowPreset preset) {
    return TimeWindowSelection._(
      type: TimeWindowType.preset,
      preset: preset,
    );
  }

  factory TimeWindowSelection.custom(TimeOfDay customTime) {
    return TimeWindowSelection._(
      type: TimeWindowType.custom,
      customTime: customTime,
    );
  }

  factory TimeWindowSelection.fromJson(Map<String, dynamic> json) {
    final type = TimeWindowType.values.firstWhere(
      (value) => value.name == json['type'],
    );
    switch (type) {
      case TimeWindowType.preset:
        return TimeWindowSelection.preset(
          TimeWindowPreset.values.firstWhere(
            (value) => value.name == json['preset'],
          ),
        );
      case TimeWindowType.custom:
        final time = json['time'] as String;
        final parts = time.split(':');
        return TimeWindowSelection.custom(
          TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          ),
        );
    }
  }

  final TimeWindowType type;
  final TimeWindowPreset? preset;
  final TimeOfDay? customTime;

  bool get isPreset => type == TimeWindowType.preset;

  bool get isCustom => type == TimeWindowType.custom;

  String get displayLabel {
    if (isPreset) {
      switch (preset!) {
        case TimeWindowPreset.morning:
          return 'Morning';
        case TimeWindowPreset.afternoon:
          return 'Afternoon';
        case TimeWindowPreset.evening:
          return 'Evening';
      }
    }
    final time = customTime!;
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final periodLabel = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $periodLabel';
  }

  Map<String, dynamic> toJson() {
    switch (type) {
      case TimeWindowType.preset:
        return {
          'type': type.name,
          'preset': preset!.name,
        };
      case TimeWindowType.custom:
        return {
          'type': type.name,
          'time': '${customTime!.hour.toString().padLeft(2, '0')}:${customTime!.minute.toString().padLeft(2, '0')}',
        };
    }
  }

  @override
  List<Object?> get props => [type, preset, customTime?.hour, customTime?.minute];
}

/// Distinguishes preset versus custom time windows.
enum TimeWindowType { preset, custom }

/// Optional quiet hours configuration.
class QuietHours extends Equatable {
  const QuietHours({
    required this.start,
    required this.end,
  });

  factory QuietHours.defaultRange() {
    return const QuietHours(
      start: TimeOfDay(hour: 22, minute: 0),
      end: TimeOfDay(hour: 7, minute: 0),
    );
  }

  factory QuietHours.fromJson(Map<String, dynamic> json) {
    return QuietHours(
      start: _timeFromJson(json['start'] as String),
      end: _timeFromJson(json['end'] as String),
    );
  }

  final TimeOfDay start;
  final TimeOfDay end;

  Map<String, dynamic> toJson() {
    return {
      'start': _timeToJson(start),
      'end': _timeToJson(end),
    };
  }

  @override
  List<Object?> get props => [start.hour, start.minute, end.hour, end.minute];
}

String _timeToJson(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

TimeOfDay _timeFromJson(String raw) {
  final parts = raw.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

/// Template metadata surfaced in the onboarding template picker.
class HabitTemplate extends Equatable {
  const HabitTemplate({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.unit,
    required this.defaultTarget,
    required this.defaultWindows,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
  final HabitUnit unit;
  final int defaultTarget;
  final List<TimeWindowSelection> defaultWindows;

  @override
  List<Object?> get props => [id, name, emoji, unit, defaultTarget, defaultWindows];
}

/// Representation of the user's customised selection derived from a template.
class SelectedHabit extends Equatable {
  const SelectedHabit({
    required this.templateId,
    required this.name,
    required this.unit,
    required this.target,
    required this.windows,
    this.quietHours,
  });

  factory SelectedHabit.fromTemplate(HabitTemplate template) {
    return SelectedHabit(
      templateId: template.id,
      name: template.name,
      unit: template.unit,
      target: template.defaultTarget,
      windows: template.defaultWindows,
      quietHours: QuietHours.defaultRange(),
    );
  }

  factory SelectedHabit.fromJson(Map<String, dynamic> json) {
    return SelectedHabit(
      templateId: json['templateId'] as String,
      name: json['name'] as String,
      unit: HabitUnit.values.firstWhere(
        (value) => value.name == json['unit'],
      ),
      target: json['target'] as int,
      windows: (json['windows'] as List<dynamic>)
          .map((raw) => TimeWindowSelection.fromJson(raw as Map<String, dynamic>))
          .toList(),
      quietHours: json['quietHours'] == null
          ? null
          : QuietHours.fromJson(json['quietHours'] as Map<String, dynamic>),
    );
  }

  SelectedHabit copyWith({
    String? name,
    HabitUnit? unit,
    int? target,
    List<TimeWindowSelection>? windows,
    QuietHours? quietHours,
  }) {
    return SelectedHabit(
      templateId: templateId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      target: target ?? this.target,
      windows: windows ?? this.windows,
      quietHours: quietHours ?? this.quietHours,
    );
  }

  final String templateId;
  final String name;
  final HabitUnit unit;
  final int target;
  final List<TimeWindowSelection> windows;
  final QuietHours? quietHours;

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'name': name,
      'unit': unit.name,
      'target': target,
      'windows': windows.map((window) => window.toJson()).toList(),
      'quietHours': quietHours?.toJson(),
    };
  }

  @override
  List<Object?> get props => [templateId, name, unit, target, windows, quietHours];
}

/// A curated selection of starter templates offered during onboarding.
final defaultHabitTemplates = <HabitTemplate>[
  HabitTemplate(
    id: 'drink-water',
    name: 'Drink Water',
    emoji: '💧',
    description: 'Stay hydrated with a quick reminder.',
    unit: HabitUnit.milliliters,
    defaultTarget: 250,
    defaultWindows: List.unmodifiable([
      TimeWindowSelection.preset(TimeWindowPreset.morning),
      TimeWindowSelection.preset(TimeWindowPreset.afternoon),
    ]),
  ),
  HabitTemplate(
    id: 'ten-minute-walk',
    name: '10-min Walk',
    emoji: '🚶',
    description: 'Stretch your legs with a brisk walk.',
    unit: HabitUnit.minutes,
    defaultTarget: 10,
    defaultWindows: List.unmodifiable([
      TimeWindowSelection.preset(TimeWindowPreset.afternoon),
    ]),
  ),
  HabitTemplate(
    id: 'mindfulness',
    name: 'Mindfulness 5 min',
    emoji: '🧘',
    description: 'Recharge with a short mindful break.',
    unit: HabitUnit.minutes,
    defaultTarget: 5,
    defaultWindows: List.unmodifiable([
      TimeWindowSelection.preset(TimeWindowPreset.morning),
      TimeWindowSelection.preset(TimeWindowPreset.evening),
    ]),
  ),
  HabitTemplate(
    id: 'read-pages',
    name: 'Read 10 pages',
    emoji: '📚',
    description: 'Keep learning every day.',
    unit: HabitUnit.pages,
    defaultTarget: 10,
    defaultWindows: List.unmodifiable([
      TimeWindowSelection.preset(TimeWindowPreset.evening),
    ]),
  ),
  HabitTemplate(
    id: 'stretch',
    name: 'Stretch',
    emoji: '🤸',
    description: 'Release tension with quick stretches.',
    unit: HabitUnit.minutes,
    defaultTarget: 3,
    defaultWindows: List.unmodifiable([
      TimeWindowSelection.preset(TimeWindowPreset.morning),
    ]),
  ),
];
