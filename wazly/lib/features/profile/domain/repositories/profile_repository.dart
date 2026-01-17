import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';

/// Repository interface for profile operations
abstract class ProfileRepository {
  /// Get the user profile
  Future<Either<Failure, ProfileEntity>> getProfile();

  /// Update the user profile
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity profile);

  /// Check if profile exists
  Future<bool> hasProfile();
}
