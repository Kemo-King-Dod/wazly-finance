// lib/core/presentation/bloc/settings/settings_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazly/core/presentation/bloc/settings/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs)
      : super(const SettingsState(
          languageCode: 'en',
          currencyCode: 'LYD',
        )) {
    _loadSettings();
  }

  void _loadSettings() {
    final lang = _prefs.getString('pref_language') ?? 'en';
    final country = _prefs.getString('pref_country');
    final curr = _prefs.getString('pref_currency') ?? 'LYD';

    // Daily reminder prefs
    final dailyEnabled = _prefs.getBool('pref_daily_reminders') ?? false;
    final dailyHour = _prefs.getInt('pref_daily_hour') ?? 9;
    final dailyMinute = _prefs.getInt('pref_daily_minute') ?? 0;
    final dailyDaysList = _prefs.getStringList('pref_daily_days');
    final dailyDays = dailyDaysList != null
        ? dailyDaysList.map(int.parse).toSet()
        : <int>{1, 2, 3, 4, 5, 6, 7};

    // Weekly reminder prefs
    final weeklyEnabled = _prefs.getBool('pref_weekly_review') ?? false;
    final weeklyHour = _prefs.getInt('pref_weekly_hour') ?? 16;
    final weeklyMinute = _prefs.getInt('pref_weekly_minute') ?? 30;
    final weeklyDay = _prefs.getInt('pref_weekly_day') ?? 5; // Friday

    emit(SettingsState(
      languageCode: lang,
      countryCode: country,
      currencyCode: curr,
      isReady: true,
      dailyRemindersEnabled: dailyEnabled,
      dailyReminderHour: dailyHour,
      dailyReminderMinute: dailyMinute,
      dailyActiveDays: dailyDays,
      weeklyReviewEnabled: weeklyEnabled,
      weeklyReminderHour: weeklyHour,
      weeklyReminderMinute: weeklyMinute,
      weeklyReminderDay: weeklyDay,
    ));
  }

  Future<void> updateLanguage(String newLang) async {
    await _prefs.setString('pref_language', newLang);
    emit(state.copyWith(languageCode: newLang));
  }

  Future<void> updateCountry(String newCountry) async {
    await _prefs.setString('pref_country', newCountry);
    emit(state.copyWith(countryCode: newCountry));
  }

  Future<void> updateCurrency(String newCurrency) async {
    await _prefs.setString('pref_currency', newCurrency);
    emit(state.copyWith(currencyCode: newCurrency));
  }

  Future<void> updateLocaleSetup(
      String lang, String country, String curr) async {
    await _prefs.setString('pref_language', lang);
    await _prefs.setString('pref_country', country);
    await _prefs.setString('pref_currency', curr);
    await _prefs.setBool('has_completed_locale_setup', true);
    emit(state.copyWith(
      languageCode: lang,
      countryCode: country,
      currencyCode: curr,
      isReady: true,
    ));
  }

  // ── Daily reminder controls ──────────────────

  Future<void> toggleDailyReminders(bool value) async {
    await _prefs.setBool('pref_daily_reminders', value);
    emit(state.copyWith(dailyRemindersEnabled: value));
  }

  Future<void> updateDailyTime(int hour, int minute) async {
    await _prefs.setInt('pref_daily_hour', hour);
    await _prefs.setInt('pref_daily_minute', minute);
    emit(state.copyWith(dailyReminderHour: hour, dailyReminderMinute: minute));
  }

  Future<void> updateDailyActiveDays(Set<int> days) async {
    await _prefs.setStringList(
        'pref_daily_days', days.map((d) => d.toString()).toList());
    emit(state.copyWith(dailyActiveDays: days));
  }

  // ── Weekly reminder controls ─────────────────

  Future<void> toggleWeeklyReview(bool value) async {
    await _prefs.setBool('pref_weekly_review', value);
    emit(state.copyWith(weeklyReviewEnabled: value));
  }

  Future<void> updateWeeklyDay(int weekday) async {
    await _prefs.setInt('pref_weekly_day', weekday);
    emit(state.copyWith(weeklyReminderDay: weekday));
  }

  Future<void> updateWeeklyTime(int hour, int minute) async {
    await _prefs.setInt('pref_weekly_hour', hour);
    await _prefs.setInt('pref_weekly_minute', minute);
    emit(state.copyWith(
        weeklyReminderHour: hour, weeklyReminderMinute: minute));
  }
}
