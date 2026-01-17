import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _passwordKey = 'wallet_password';

  /// Check if biometrics are available
  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  /// Authenticate using biometrics
  Future<bool> authenticateBiometric({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
        biometricOnly: false,
      );
    } catch (e) {
      return false;
    }
  }

  /// Set or change the password
  Future<void> setPassword(String password) async {
    await _storage.write(key: _passwordKey, value: password);
  }

  /// Verify if the password is correct
  Future<bool> verifyPassword(String password) async {
    final storedPassword = await _storage.read(key: _passwordKey);
    return storedPassword == password;
  }

  /// Check if the vault is locked (Security Enabled)
  bool isSecurityEnabled() {
    final settingsBox = Hive.box('settings');
    return settingsBox.get('isSecurityEnabled', defaultValue: false);
  }

  /// Disable security
  Future<void> disableSecurity() async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('isSecurityEnabled', false);
    await settingsBox.put('securityType', 'none');
    await _storage.delete(key: _passwordKey);
  }
}
