import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:wazly/core/services/security_service.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/core/presentation/pages/pin_lock_screen.dart';
import 'package:wazly/l10n/app_localizations.dart';

class SecurityScreen extends StatefulWidget {
  SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _securityService = GetIt.instance<SecurityService>();

  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = false;
  int _autoLockDelayMinutes = 0;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final canCheck = await _securityService.canCheckBiometrics();
    final isPinSet = await _securityService.isPinSetup;
    // App lock is enabled if the user explicitly enabled it AND there's a PIN
    final appLock = _securityService.isAppLockEnabled && isPinSet;

    setState(() {
      _canCheckBiometrics = canCheck;
      _isAppLockEnabled = appLock;
      _isBiometricEnabled = _securityService.isBiometricEnabled;
      _autoLockDelayMinutes = _securityService.autoLockDelayMinutes;
    });
  }

  Future<void> _toggleAppLock(bool value) async {
    if (value) {
      // Trying to enable. If no PIN is setup, we must navigate to PIN setup first
      final isPinSet = await _securityService.isPinSetup;
      if (!isPinSet) {
        if (!mounted) return;
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PinLockScreen(mode: PinLockMode.setup),
          ),
        );
        if (result == true) {
          // PIN setup successful
          setState(() {
            _isAppLockEnabled = true;
          });
          _loadSettings();
        }
      } else {
        await _securityService.setAppLockEnabled(true);
        setState(() {
          _isAppLockEnabled = true;
        });
      }
    } else {
      // Prompt user to verify PIN before turning off App Lock
      if (!mounted) return;
      final success = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PinLockScreen(mode: PinLockMode.verify),
        ),
      );
      if (success == true) {
        await _securityService.removePin(); // Removing PIN disables everything
        setState(() {
          _isAppLockEnabled = false;
          _isBiometricEnabled = false;
        });
      }
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (!mounted) return;
    // Require PIN verify to toggle biometrics on OR off
    final success = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PinLockScreen(mode: PinLockMode.verify)),
    );
    if (success != true) return;

    if (!value) {
      await _securityService.setBiometricEnabled(false);
      setState(() => _isBiometricEnabled = false);
      return;
    }

    final enrolled = await _securityService.authenticateWithBiometrics(AppLocalizations.of(context)!.authenticateToEnableBiometrics);
    if (enrolled) {
      await _securityService.setBiometricEnabled(true);
      setState(() => _isBiometricEnabled = true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.biometricFailed)),
      );
    }
  }

  Future<void> _changeAutoLockDelay() async {
    final l10n = AppLocalizations.of(context)!;
    final options = <int, String>{
      0: l10n.delayImmediately,
      1: l10n.delayOneMinute,
      5: l10n.delayFiveMinutes,
      15: l10n.delayFifteenMinutes,
    };

    final result = await showDialog<int?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
          title: Text(l10n.autoLockDelayTitle, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.entries.map((e) {
              return ListTile(
                title: Text(e.value, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                trailing: _autoLockDelayMinutes == e.key ? Icon(FluentIcons.checkmark_circle_24_filled, color: Theme.of(context).primaryColor) : null,
                onTap: () => Navigator.pop(context, e.key),
              );
            }).toList(),
          ),
        );
      },
    );

    if (result != null) {
      await _securityService.setAutoLockDelayMinutes(result);
      setState(() => _autoLockDelayMinutes = result);
    }
  }

  Future<void> _changePin() async {
    // 1. Verify old PIN
    final verified = await Navigator.push(context, MaterialPageRoute(builder: (_) => PinLockScreen(mode: PinLockMode.verify)));
    if (verified != true) return;

    // 2. Setup new PIN
    if (!mounted) return;
    final newSetup = await Navigator.push(context, MaterialPageRoute(builder: (_) => PinLockScreen(mode: PinLockMode.setup)));
    if (newSetup == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.pinChangedSuccessfully)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.security, style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Basic Lock Toggles
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _isAppLockEnabled,
                  onChanged: _toggleAppLock,
                  title: Text(l10n.appLock, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text(l10n.requirePinToOpenApp, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  activeTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  activeThumbColor: Theme.of(context).primaryColor,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
                if (_isAppLockEnabled) ...[
                  Divider(color: AppTheme.borderLight, height: 1),
                  if (_canCheckBiometrics)
                    SwitchListTile(
                      value: _isBiometricEnabled,
                      onChanged: _toggleBiometrics,
                      title: Text(l10n.biometricUnlock, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                      subtitle: Text(l10n.useFingerprintOrFaceId, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      activeTrackColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  activeThumbColor: Theme.of(context).primaryColor,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    ),
                ],
              ],
            ),
          ),
          if (_isAppLockEnabled) ...[
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                l10n.advancedSettings,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(l10n.autoLockDelayTitle, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text(
                      _autoLockDelayMinutes == 0 ? l10n.delayImmediately : l10n.afterXMinutes(_autoLockDelayMinutes),
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    trailing: Icon(FluentIcons.chevron_right_24_regular, color: AppTheme.textSecondary),
                    onTap: _changeAutoLockDelay,
                  ),
                  Divider(color: AppTheme.borderLight, height: 1),
                  ListTile(
                    title: Text(l10n.changePinTitle, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                    trailing: Icon(FluentIcons.chevron_right_24_regular, color: AppTheme.textSecondary),
                    onTap: _changePin,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
