import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'settings_state.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class ChangeLocale extends SettingsEvent {
  final Locale locale;
  const ChangeLocale(this.locale);

  @override
  List<Object?> get props => [locale];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ToggleSecurity extends SettingsEvent {
  final SecurityType type;
  final String? password;
  const ToggleSecurity(this.type, {this.password});

  @override
  List<Object?> get props => [type, password];
}

class BackupData extends SettingsEvent {
  const BackupData();
}

class RestoreData extends SettingsEvent {
  const RestoreData();
}

class ResetSystem extends SettingsEvent {
  const ResetSystem();
}

class ToggleNavigationRail extends SettingsEvent {
  final bool isEnabled;
  const ToggleNavigationRail(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}
