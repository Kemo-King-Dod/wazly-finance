import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
