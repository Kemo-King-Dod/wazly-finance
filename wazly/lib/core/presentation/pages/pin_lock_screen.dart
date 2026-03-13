import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:wazly/core/services/security_service.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/l10n/app_localizations.dart';

enum PinLockMode {
  unlock, // User is opening the app
  verify, // User is verifying to perform an action (e.g. change settings)
  setup, // User is creating a new PIN
}

class PinLockScreen extends StatefulWidget {
  final PinLockMode mode;
  final bool canCancel; // Usually true for verify/setup, false for unlock
  final VoidCallback? onUnlock;

  PinLockScreen({
    super.key,
    required this.mode,
    this.canCancel = true,
    this.onUnlock,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final _securityService = GetIt.instance<SecurityService>();

  String _enteredPin = '';
  String _firstSetupPin = '';
  bool _isConfirming = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // For unlock mode, automatically try biometrics if enabled
    if (widget.mode == PinLockMode.unlock) {
      _checkBiometricUnlock();
    }
  }

  Future<void> _checkBiometricUnlock() async {
    final enabled = _securityService.isBiometricEnabled;
    if (enabled) {
      final success = await _securityService.authenticateWithBiometrics('Unlock Wazly');
      if (success) {
        if (widget.onUnlock != null) {
          widget.onUnlock!();
        } else if (mounted) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _hasError = false;
      });
      if (_enteredPin.length == 4) {
        _onPinComplete();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _hasError = false;
      });
    }
  }

  Future<void> _onPinComplete() async {
    // Small delay to let user see the last dot filled
    await Future.delayed(Duration(milliseconds: 150));
    if (!mounted) return;

    if (widget.mode == PinLockMode.setup) {
      if (!_isConfirming) {
        // Step 1 of setup complete
        setState(() {
          _firstSetupPin = _enteredPin;
          _enteredPin = '';
          _isConfirming = true;
        });
      } else {
        // Step 2 of setup: confirmation
        if (_enteredPin == _firstSetupPin) {
          await _securityService.setupPin(_enteredPin);
          if (mounted) Navigator.pop(context, true);
        } else {
          if (mounted) _showError(AppLocalizations.of(context)!.pinsDoNotMatch);
          setState(() {
            _enteredPin = '';
            _firstSetupPin = '';
            _isConfirming = false;
          });
        }
      }
    } else {
      final isValid = await _securityService.verifyPin(_enteredPin);
      if (isValid) {
        if (widget.onUnlock != null) {
          widget.onUnlock!();
        } else if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) _showError(AppLocalizations.of(context)!.incorrectPinTryAgain);
      }
    }
  }

  void _showError(String msg) {
    setState(() {
      _hasError = true;
      _errorMessage = msg;
      _enteredPin = ''; // Reset on error
    });
  }

  String _getTitleText(BuildContext context) {
    if (widget.mode == PinLockMode.setup) {
      return _isConfirming ? AppLocalizations.of(context)!.verifyNewPinTitle : AppLocalizations.of(context)!.createPinTitle;
    } else if (widget.mode == PinLockMode.verify) {
      return AppLocalizations.of(context)!.verifyPinToContinue;
    } else {
      return AppLocalizations.of(context)!.enterYourPin;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If unlocking, user shouldn't be able to just pop the navigator with back button
    return PopScope(
      canPop: widget.mode != PinLockMode.unlock && widget.canCancel,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: widget.mode != PinLockMode.unlock && widget.canCancel,
          iconTheme: IconThemeData(color: AppTheme.textPrimary),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/logo/wazlyLogo.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 24),
              Text(
                _getTitleText(context),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 40),

              // PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isFilled ? Theme.of(context).primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFilled ? Theme.of(context).primaryColor : AppTheme.borderLight,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 24),

              // Error Message
              SizedBox(
                height: 24,
                child: _hasError
                    ? Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : null,
              ),

              Spacer(),

              // Numpad
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildNumpadRow(['1', '2', '3']),
                    SizedBox(height: 16),
                    _buildNumpadRow(['4', '5', '6']),
                    SizedBox(height: 16),
                    _buildNumpadRow(['7', '8', '9']),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNumpadButton(
                          child: widget.mode == PinLockMode.unlock
                              ? Icon(FluentIcons.fingerprint_24_regular, color: AppTheme.textSecondary, size: 32)
                              : SizedBox(width: 72), // Empty space or biometric icon
                          onTap: widget.mode == PinLockMode.unlock ? _checkBiometricUnlock : () {},
                        ),
                        _buildNumpadButton(
                          child: Text('0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          onTap: () => _onNumberPressed('0'),
                        ),
                        _buildNumpadButton(
                          child: Icon(FluentIcons.backspace_24_regular, color: AppTheme.textSecondary, size: 28),
                          onTap: _onDeletePressed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) {
        return _buildNumpadButton(
          child: Text(
            n,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          onTap: () => _onNumberPressed(n),
        );
      }).toList(),
    );
  }

  Widget _buildNumpadButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}
