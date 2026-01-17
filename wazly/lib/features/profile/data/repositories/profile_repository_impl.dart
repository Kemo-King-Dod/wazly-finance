import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/profile_model.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final profile = await localDataSource.getProfile();
      return Right(profile.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get profile: $e'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
    ProfileEntity profile,
  ) async {
    try {
      final profileModel = ProfileModel.fromEntity(profile);
      final updatedProfile = await localDataSource.updateProfile(profileModel);
      return Right(updatedProfile.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to update profile: $e'));
    }
  }

  @override
  Future<bool> hasProfile() async {
    try {
      return await localDataSource.hasProfile();
    } catch (e) {
      return false;
    }
  }
}
