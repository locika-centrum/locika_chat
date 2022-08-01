import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings_data.dart';

class AppSettings {
  static final AppSettings _instance = AppSettings._internal();
  late SharedPreferences _preferences;
  late AppSettingsData _data;

  factory AppSettings() {
    return _instance;
  }

  AppSettings._internal() {}

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    _data = AppSettingsData(_preferences);
  }

  AppSettingsData get data => _data;
}