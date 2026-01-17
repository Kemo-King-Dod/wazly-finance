import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/security_service.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_state.dart';

class SecurityLockPage extends StatefulWidget {
  final Widget child;
  const SecurityLockPage({super.key, required this.child});

  @override
  State<SecurityLockPage> createState() => _SecurityLockPageState();
}

class _SecurityLockPageState extends State<SecurityLockPage> {
  bool _isLocked = true;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  Future<void> _checkSecurity() async {
    final securityService = sl<SecurityService>();
    if (securityService.isSecurityEnabled()) {
      final settingsState = context.read<SettingsBloc>().state;
      if (settingsState.securityType == SecurityType.biometric) {
        final authenticated = await securityService.authenticateBiometric(
          reason: 'Authenticate to unlock Wazly',
        );
        if (authenticated) {
          setState(() {
            _isLocked = false;
          });
        }
      }
    } else {
      setState(() {
        _isLocked = false;
      });
    }
  }

  Future<void> _verifyPassword() async {
    final securityService = sl<SecurityService>();
    final isValid = await securityService.verifyPassword(
      _passwordController.text,
    );
    if (!mounted) return;
    if (isValid) {
      setState(() {
        _isLocked = false;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid password')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        // Automatically trigger biometric if it's enabled and we are locked
        if (_isLocked &&
            sl<SecurityService>().isSecurityEnabled() &&
            state.securityType == SecurityType.biometric) {
          _checkSecurity();
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (!_isLocked) return widget.child;

          final l10n = AppLocalizations.of(context)!;

          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.incomeColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppTheme.incomeColor,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.appTitle,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authenticateToUnlock,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (state.securityType == SecurityType.password) ...[
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          letterSpacing: 8,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••',
                          hintStyle: TextStyle(
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.incomeColor),
                          ),
                        ),
                        onSubmitted: (_) => _verifyPassword(),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _verifyPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.incomeColor,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    if (state.securityType == SecurityType.biometric)
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.fingerprint_rounded,
                              size: 64,
                              color: AppTheme.incomeColor,
                            ),
                            onPressed: _checkSecurity,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _checkSecurity,
                            child: Text(
                              l10n.retry,
                              style: const TextStyle(
                                color: AppTheme.incomeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
