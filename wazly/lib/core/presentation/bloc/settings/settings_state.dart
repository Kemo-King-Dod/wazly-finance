// lib/core/presentation/bloc/settings/settings_state.dart
import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String languageCode;
  final String? countryCode;
  final String currencyCode;
  final bool isReady;

  // Daily reminder
  final bool dailyRemindersEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;
  /// Selected weekdays using DateTime weekday values: 1=Mon…7=Sun
  final Set<int> dailyActiveDays;

  // Weekly review reminder
  final bool weeklyReviewEnabled;
  final int weeklyReminderHour;
  final int weeklyReminderMinute;
  final int weeklyReminderDay; // DateTime weekday: 1=Mon…7=Sun

  const SettingsState({
    required this.languageCode,
    this.countryCode,
    required this.currencyCode,
    this.isReady = false,
    this.dailyRemindersEnabled = false,
    this.dailyReminderHour = 9,
    this.dailyReminderMinute = 0,
    this.dailyActiveDays = const {1, 2, 3, 4, 5, 6, 7},
    this.weeklyReviewEnabled = false,
    this.weeklyReminderHour = 16,
    this.weeklyReminderMinute = 30,
    this.weeklyReminderDay = 5, // Friday
  });

  SettingsState copyWith({
    String? languageCode,
    String? countryCode,
    String? currencyCode,
    bool? isReady,
    bool? dailyRemindersEnabled,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    Set<int>? dailyActiveDays,
    bool? weeklyReviewEnabled,
    int? weeklyReminderHour,
    int? weeklyReminderMinute,
    int? weeklyReminderDay,
  }) {
    return SettingsState(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      isReady: isReady ?? this.isReady,
      dailyRemindersEnabled: dailyRemindersEnabled ?? this.dailyRemindersEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
      dailyActiveDays: dailyActiveDays ?? this.dailyActiveDays,
      weeklyReviewEnabled: weeklyReviewEnabled ?? this.weeklyReviewEnabled,
      weeklyReminderHour: weeklyReminderHour ?? this.weeklyReminderHour,
      weeklyReminderMinute: weeklyReminderMinute ?? this.weeklyReminderMinute,
      weeklyReminderDay: weeklyReminderDay ?? this.weeklyReminderDay,
    );
  }

  @override
  List<Object?> get props => [
        languageCode,
        countryCode,
        currencyCode,
        isReady,
        dailyRemindersEnabled,
        dailyReminderHour,
        dailyReminderMinute,
        dailyActiveDays,
        weeklyReviewEnabled,
        weeklyReminderHour,
        weeklyReminderMinute,
        weeklyReminderDay,
      ];
}
