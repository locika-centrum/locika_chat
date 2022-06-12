import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides access to persistent user settings of the application
class AppSettings {
  static late SharedPreferences _preferences;

  static final List<Map> _optionPreferences = [
    {
      'key': 'age_category',
      'values': ['dítě', 'teenager', 'student', 'dospělý'],
    },
    {
      'key': 'game_size',
      'values': ['malá', 'střední', 'velká', 'největší'],
    },
  ];

  /// Initializes the settings and populates in memory storage
  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static ValueNotifier<String?> nickName =
      ValueNotifier(_preferences.getString('nick_name'));
  static ValueNotifier<int?> ageCategory =
      ValueNotifier(_preferences.getInt('age_category'));
  static ValueNotifier<int> gameSize =
      ValueNotifier(_preferences.getInt('game_size') ?? 0);
  static ValueNotifier<bool> violetModeOn =
      ValueNotifier(_preferences.getBool('violet_mode') ?? false);

  static void setNickName(String? name) {
    nickName.value = name;
    if (name == null) {
      _preferences.remove('nick_name');
    } else {
      _preferences.setString('nick_name', name);
    }
  }

  static bool isEligibleForVioletMode() {
    return ageCategory.value! < getAgeCategories().length - 1;
  }

  static List<String> getAgeCategories() {
    return _optionPreferences
        .singleWhere((element) => element['key'] == 'age_category')['values'];
  }

  static void setAgeCategory(int category) {
    ageCategory.value = category;
    _preferences.setInt('age_category', category);
  }

  static List<String> getGameSizes() {
    return _optionPreferences
        .singleWhere((element) => element['key'] == 'game_size')['values'];
  }

  static void setGameSize(int size) {
    gameSize.value = size;
    _preferences.setInt('game_size', size);
  }

  static void toggleVioletMode() {
    violetModeOn.value = !violetModeOn.value;
    _preferences.setBool('violet_mode', violetModeOn.value);
  }
}
