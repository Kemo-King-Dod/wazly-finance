import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for authentication using SharedPreferences
abstract class AuthLocalDataSource {
  Future<bool> isFirstLaunch();
  Future<int> getLaunchCount();
  Future<void> setLaunchCount(int count);
  Future<void> setFirstLaunchComplete();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyLaunchCount = 'launch_count';

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<bool> isFirstLaunch() async {
    return sharedPreferences.getBool(_keyFirstLaunch) ?? true;
  }

  @override
  Future<int> getLaunchCount() async {
    return sharedPreferences.getInt(_keyLaunchCount) ?? 0;
  }

  @override
  Future<void> setLaunchCount(int count) async {
    await sharedPreferences.setInt(_keyLaunchCount, count);
  }

  @override
  Future<void> setFirstLaunchComplete() async {
    await sharedPreferences.setBool(_keyFirstLaunch, false);
  }
}
