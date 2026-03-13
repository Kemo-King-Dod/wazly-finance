import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:wazly/core/services/security_service.dart';
import 'package:wazly/core/presentation/pages/pin_lock_screen.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> with WidgetsBindingObserver {
  final _securityService = GetIt.instance<SecurityService>();
  bool _isLocked = false;
  DateTime? _pausedAt;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLock();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _userInteracted() {
    if (!_isLocked) {
      _startInactivityTimer();
    }
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    final enabled = _securityService.isAppLockEnabled;
    if (!enabled) return;

    final delay = _securityService.autoLockDelayMinutes;
    // 0 means lock only when backgrounded immediately. 
    // We do not auto-lock while app is foreground for delay=0.
    if (delay > 0) {
      _inactivityTimer = Timer(Duration(minutes: delay), () {
        if (mounted && !_isLocked) {
          setState(() => _isLocked = true);
        }
      });
    }
  }

  Future<void> _checkInitialLock() async {
    final enabled = _securityService.isAppLockEnabled;
    final isSetup = await _securityService.isPinSetup;
    if (enabled && isSetup) {
      if (mounted) setState(() => _isLocked = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final enabled = _securityService.isAppLockEnabled;
    if (!enabled) {
      _pausedAt = null;
      return;
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _inactivityTimer?.cancel();
      if (!_isLocked) {
        _pausedAt ??= DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedAt != null && !_isLocked) {
        final elapsedSeconds = DateTime.now().difference(_pausedAt!).inSeconds;
        final timeoutMinutes = _securityService.autoLockDelayMinutes;

        // If timeout is 0, any backgrounding instantly triggers a lock.
        // If timeout > 0, lock if backgrounded longer than the setup threshold.
        if (timeoutMinutes == 0 || elapsedSeconds >= (timeoutMinutes * 60)) {
          setState(() {
            _isLocked = true;
          });
        }
      }
      _pausedAt = null;
      if (!_isLocked) {
        _startInactivityTimer();
      }
    }
  }

  void _onUnlockSuccessful() {
    setState(() {
      _isLocked = false;
      _pausedAt = null;
    });
    _startInactivityTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: PinLockScreen(
              mode: PinLockMode.unlock,
              canCancel: false,
              onUnlock: _onUnlockSuccessful,
            ),
          ),
        ],
      );
    }

    return Listener(
      onPointerDown: (_) => _userInteracted(),
      onPointerMove: (_) => _userInteracted(),
      onPointerUp: (_) => _userInteracted(),
      child: widget.child,
    );
  }
}
