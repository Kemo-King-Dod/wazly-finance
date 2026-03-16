import 'package:shared_preferences/shared_preferences.dart';

class CoachMarkService {
  static const _prefix = 'coach_tour_';

  static Future<bool> hasSeenTour(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$tourId') ?? false;
  }

  static Future<void> completeTour(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tourId', true);
  }

  static Future<void> resetAllTours() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_prefix)) {
        await prefs.remove(key);
      }
    }
  }
}
