import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _settingsBoxName = 'settings';
  static const String _localeKey = 'locale';

  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeLocale>(_onChangeLocale);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final box = await Hive.openBox(_settingsBoxName);
    final localeString = box.get(_localeKey, defaultValue: 'en');
    emit(state.copyWith(locale: Locale(localeString)));
  }

  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<SettingsState> emit,
  ) async {
    final box = await Hive.openBox(_settingsBoxName);
    await box.put(_localeKey, event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }
}
