import 'package:hive/hive.dart';
import '../models/profile_model.dart';

/// Local data source for profile using Hive
abstract class ProfileLocalDataSource {
  /// Get the user profile
  Future<ProfileModel> getProfile();

  /// Update the user profile
  Future<ProfileModel> updateProfile(ProfileModel profile);

  /// Check if profile exists
  Future<bool> hasProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _boxName = 'profile';
  static const String _profileKey = 'user_profile';

  @override
  Future<ProfileModel> getProfile() async {
    final box = await Hive.openBox<ProfileModel>(_boxName);
    final profile = box.get(_profileKey);

    if (profile == null) {
      // Return default profile if none exists
      final defaultProfile = ProfileModel.defaultProfile();
      await box.put(_profileKey, defaultProfile);
      return defaultProfile;
    }

    return profile;
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final box = await Hive.openBox<ProfileModel>(_boxName);
    await box.put(_profileKey, profile);
    return profile;
  }

  @override
  Future<bool> hasProfile() async {
    final box = await Hive.openBox<ProfileModel>(_boxName);
    return box.containsKey(_profileKey);
  }
}
