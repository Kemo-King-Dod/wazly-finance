import '../repositories/auth_repository.dart';

/// Use case to increment app launch counter
class IncrementLaunchCountUseCase {
  final AuthRepository repository;

  IncrementLaunchCountUseCase(this.repository);

  Future<void> call() async {
    await repository.incrementLaunchCount();
  }
}
