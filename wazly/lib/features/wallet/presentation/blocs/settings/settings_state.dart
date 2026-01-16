import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final Locale locale;

  const SettingsState({this.locale = const Locale('en')});

  @override
  List<Object?> get props => [locale];

  SettingsState copyWith({Locale? locale}) {
    return SettingsState(locale: locale ?? this.locale);
  }
}
