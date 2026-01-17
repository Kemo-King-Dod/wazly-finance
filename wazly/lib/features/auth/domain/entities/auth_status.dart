/// Authentication status entity
class AuthStatus {
  final bool isFirstLaunch;
  final int launchCount;
  final bool shouldShowWelcome;

  const AuthStatus({
    required this.isFirstLaunch,
    required this.launchCount,
    required this.shouldShowWelcome,
  });

  AuthStatus copyWith({
    bool? isFirstLaunch,
    int? launchCount,
    bool? shouldShowWelcome,
  }) {
    return AuthStatus(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      launchCount: launchCount ?? this.launchCount,
      shouldShowWelcome: shouldShowWelcome ?? this.shouldShowWelcome,
    );
  }
}
