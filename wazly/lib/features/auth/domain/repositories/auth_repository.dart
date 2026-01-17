import '../entities/auth_status.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Get current authentication status
  Future<AuthStatus> getAuthStatus();

  /// Increment app launch counter
  Future<void> incrementLaunchCount();

  /// Mark welcome screen as shown
  Future<void> markWelcomeShown();
}
