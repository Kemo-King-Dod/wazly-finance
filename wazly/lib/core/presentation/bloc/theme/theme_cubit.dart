import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazly/core/theme/app_theme.dart';

class ThemeState {
  final AppThemeOption option;
  const ThemeState(this.option);
}

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'selected_theme_option';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(const ThemeState(AppThemeOption.teal)) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeName = _prefs.getString(_themeKey);
    if (themeName != null) {
      try {
        final option = AppThemeOption.values.firstWhere((e) => e.name == themeName);
        emit(ThemeState(option));
      } catch (_) {
        // Fallback to default if not found
      }
    }
  }

  Future<void> setTheme(AppThemeOption option) async {
    await _prefs.setString(_themeKey, option.name);
    emit(ThemeState(option));
  }
}
