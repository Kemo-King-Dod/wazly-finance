import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wazly/injection_container.dart';
import 'package:wazly/core/services/backup_service.dart';
import 'package:wazly/core/services/security_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _settingsBoxName = 'settings';
  static const String _localeKey = 'locale';
  static const String _isSecurityEnabledKey = 'isSecurityEnabled';
  static const String _securityTypeKey = 'securityType';
  static const String _isNavigationRailEnabledKey = 'isNavigationRailEnabled';

  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeLocale>(_onChangeLocale);
    on<ToggleSecurity>(_onToggleSecurity);
    on<ToggleNavigationRail>(_onToggleNavigationRail);
    on<BackupData>(_onBackupData);
    on<RestoreData>(_onRestoreData);
    on<ResetSystem>(_onResetSystem);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final box = await Hive.openBox(_settingsBoxName);
    final localeString = box.get(_localeKey, defaultValue: 'en');
    final isSecurityEnabled = box.get(
      _isSecurityEnabledKey,
      defaultValue: false,
    );
    final securityTypeString = box.get(_securityTypeKey, defaultValue: 'none');
    final isNavigationRailEnabled = box.get(
      _isNavigationRailEnabledKey,
      defaultValue: false,
    );

    emit(
      state.copyWith(
        locale: Locale(localeString),
        isSecurityEnabled: isSecurityEnabled,
        securityType: SecurityType.values.byName(securityTypeString),
        isNavigationRailEnabled: isNavigationRailEnabled,
      ),
    );
  }

  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<SettingsState> emit,
  ) async {
    final box = await Hive.openBox(_settingsBoxName);
    await box.put(_localeKey, event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }

  Future<void> _onToggleSecurity(
    ToggleSecurity event,
    Emitter<SettingsState> emit,
  ) async {
    final box = await Hive.openBox(_settingsBoxName);
    final securityService = sl<SecurityService>();

    if (event.type == SecurityType.none) {
      await securityService.disableSecurity();
      emit(
        state.copyWith(
          isSecurityEnabled: false,
          securityType: SecurityType.none,
        ),
      );
    } else {
      if (event.type == SecurityType.password && event.password != null) {
        await securityService.setPassword(event.password!);
      }

      await box.put(_isSecurityEnabledKey, true);
      await box.put(_securityTypeKey, event.type.name);

      emit(state.copyWith(isSecurityEnabled: true, securityType: event.type));
    }
  }

  Future<void> _onBackupData(
    BackupData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(backupStatus: BackupStatus.loading));
    final success = await sl<BackupService>().exportBackup();
    emit(
      state.copyWith(
        backupStatus: success ? BackupStatus.success : BackupStatus.failure,
      ),
    );
  }

  Future<void> _onRestoreData(
    RestoreData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(backupStatus: BackupStatus.loading));
    final success = await sl<BackupService>().importBackup();
    emit(
      state.copyWith(
        backupStatus: success ? BackupStatus.success : BackupStatus.failure,
      ),
    );
    // If restore is successful, we might want to trigger a global reload or app restart
  }

  Future<void> _onResetSystem(
    ResetSystem event,
    Emitter<SettingsState> emit,
  ) async {
    await sl<BackupService>().clearAllData();
    emit(const SettingsState()); // Reset settings state
  }

  Future<void> _onToggleNavigationRail(
    ToggleNavigationRail event,
    Emitter<SettingsState> emit,
  ) async {
    final box = await Hive.openBox(_settingsBoxName);
    await box.put(_isNavigationRailEnabledKey, event.isEnabled);
    emit(state.copyWith(isNavigationRailEnabled: event.isEnabled));
  }
}
