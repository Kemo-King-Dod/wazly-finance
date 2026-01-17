import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum SecurityType { none, biometric, password }

enum BackupStatus { idle, loading, success, failure }

class SettingsState extends Equatable {
  final Locale locale;
  final bool isSecurityEnabled;
  final SecurityType securityType;
  final bool isNavigationRailEnabled;
  final BackupStatus backupStatus;
  final String? errorMessage;

  const SettingsState({
    this.locale = const Locale('en'),
    this.isSecurityEnabled = false,
    this.securityType = SecurityType.none,
    this.isNavigationRailEnabled = false,
    this.backupStatus = BackupStatus.idle,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    locale,
    isSecurityEnabled,
    securityType,
    isNavigationRailEnabled,
    backupStatus,
    errorMessage,
  ];

  SettingsState copyWith({
    Locale? locale,
    bool? isSecurityEnabled,
    SecurityType? securityType,
    bool? isNavigationRailEnabled,
    BackupStatus? backupStatus,
    String? errorMessage,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      isSecurityEnabled: isSecurityEnabled ?? this.isSecurityEnabled,
      securityType: securityType ?? this.securityType,
      isNavigationRailEnabled:
          isNavigationRailEnabled ?? this.isNavigationRailEnabled,
      backupStatus: backupStatus ?? this.backupStatus,
      errorMessage: errorMessage,
    );
  }
}
