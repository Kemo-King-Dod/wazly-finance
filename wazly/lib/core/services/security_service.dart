import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;
  final LocalAuthentication _localAuth;

  static const _pinKey = 'wazly_app_pin';
  static const _appLockEnabledKey = 'wazly_app_lock_enabled';
  static const _biometricEnabledKey = 'wazly_biometric_enabled';
  static const _autoLockDelayKey = 'wazly_auto_lock_delay_minutes';

  SecurityService(this._secureStorage, this._prefs, this._localAuth);

  // --- PIN Management ---

  Future<bool> get isPinSetup async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setupPin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
    await setAppLockEnabled(true);
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    return storedPin == pin;
  }

  Future<void> removePin() async {
    await _secureStorage.delete(key: _pinKey);
    await setAppLockEnabled(false);
    await setBiometricEnabled(false);
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    final isValid = await verifyPin(oldPin);
    if (!isValid) return false;
    await _secureStorage.write(key: _pinKey, value: newPin);
    return true;
  }

  // --- Settings ---

  bool get isAppLockEnabled {
    return _prefs.getBool(_appLockEnabledKey) ?? false;
  }

  Future<void> setAppLockEnabled(bool value) async {
    await _prefs.setBool(_appLockEnabledKey, value);
    if (!value) {
      await setBiometricEnabled(false);
    }
  }

  bool get isBiometricEnabled {
    return _prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool value) async {
    await _prefs.setBool(_biometricEnabledKey, value);
  }

  int get autoLockDelayMinutes {
    return _prefs.getInt(_autoLockDelayKey) ?? 0; // 0 = Immediately
  }

  Future<void> setAutoLockDelayMinutes(int minutes) async {
    await _prefs.setInt(_autoLockDelayKey, minutes);
  }

  // --- Biometrics ---

  Future<bool> canCheckBiometrics() async {
    final isAvailable = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return isAvailable && isDeviceSupported;
  }

  Future<bool> authenticateWithBiometrics(String localizedReason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      return false;
    }
  }
}
