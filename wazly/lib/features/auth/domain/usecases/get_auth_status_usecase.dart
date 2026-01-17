import '../entities/auth_status.dart';
import '../repositories/auth_repository.dart';

/// Use case to get current authentication status
class GetAuthStatusUseCase {
  final AuthRepository repository;

  GetAuthStatusUseCase(this.repository);

  Future<AuthStatus> call() async {
    return await repository.getAuthStatus();
  }
}
