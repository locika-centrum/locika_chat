import 'package:shared_preferences/shared_preferences.dart';

/// Provides access to persistent user settings of the application
class AppSettings {
  static late SharedPreferences _preferences;

  /// Initializes the settings and populates in memory storage
  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }
}