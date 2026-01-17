import '../../domain/entities/auth_status.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<AuthStatus> getAuthStatus() async {
    final isFirstLaunch = await localDataSource.isFirstLaunch();
    final launchCount = await localDataSource.getLaunchCount();

    // Show welcome on first launch OR every 5-6 launches
    final shouldShowWelcome =
        isFirstLaunch ||
        (launchCount > 0 && (launchCount % 5 == 0 || launchCount % 6 == 0));

    return AuthStatus(
      isFirstLaunch: isFirstLaunch,
      launchCount: launchCount,
      shouldShowWelcome: shouldShowWelcome,
    );
  }

  @override
  Future<void> incrementLaunchCount() async {
    final currentCount = await localDataSource.getLaunchCount();
    await localDataSource.setLaunchCount(currentCount + 1);
  }

  @override
  Future<void> markWelcomeShown() async {
    final isFirstLaunch = await localDataSource.isFirstLaunch();
    if (isFirstLaunch) {
      await localDataSource.setFirstLaunchComplete();
    }
  }
}
