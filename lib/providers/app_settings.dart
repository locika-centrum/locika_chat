import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides access to persistent user settings of the application
class AppSettings {
  static late SharedPreferences _preferences;

  static final List<Map> _optionPreferences = [
    {
      'key': 'age_category',
      'values': [
        {'category': 'dítě', 'title': 'Lehká', 'subtitle': 'vhodné pro děti'},
        {'category': 'teenager', 'title': 'Základní', 'subtitle': 'vhodné pro školáky'},
        {'category': 'student', 'title': 'Střední', 'subtitle': 'vhodné pro studenty'},
        {'category': 'dospělý', 'title': 'Expert', 'subtitle': 'vhodné pro dospělé'},
      ],
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
  static ValueNotifier<Cookie?> cookie = ValueNotifier(() {
    Cookie? result;

    if (_preferences.containsKey('cookie')) {
      result = Cookie.fromSetCookieValue(_preferences.getString('cookie')!);
      if (result.expires!.difference(DateTime.now()).isNegative) {
        result = null;
      }
    }
    return result;
  }());

  @Deprecated('not used parameter')
  static ValueNotifier<String?> advisorID =
      ValueNotifier(_preferences.getString('chat_advisor_id'));
  static ValueNotifier<String?> chatID =
      ValueNotifier(_preferences.getString('chat_id'));

  static void setCookie(Cookie cookie) {
    AppSettings.cookie.value = cookie;
    _preferences.setString('cookie', cookie.toString());
  }

  @Deprecated('not used parameter')
  static void setAdvisorID(String? id) {
    advisorID.value = id;
    id == null
        ? _preferences.remove('chat_advisor_id')
        : _preferences.setString('chat_advisor_id', id);
  }

  static void setChatID(String? id) {
    chatID.value = id;
    id == null
        ? _preferences.remove('chat_id')
        : _preferences.setString('chat_id', id);
  }

  static void setNickName(String? name) {
    nickName.value = name;
    name == null
        ? _preferences.remove('nick_name')
        : _preferences.setString('nick_name', name);
  }

  static bool isEligibleForVioletMode() {
    return ageCategory.value! < getAgeCategories().length - 1;
  }

  static List<Map> getAgeCategories() {
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

  static String get allSettings {
    return '{Nick name: ${AppSettings.nickName.value}, '
        'Age category: ${AppSettings.ageCategory.value}, '
        'Game size: ${AppSettings.gameSize.value}, '
        'Violet mode: ${AppSettings.violetModeOn.value}, '
        'Chat ID: ${AppSettings.chatID.value}, '
        'Advisor ID: ${AppSettings.advisorID.value}, '
        'Cookie: ${AppSettings.cookie.value}}';
  }

  static void resetScore() {
    // TODO
  }

  static Future<void> resetAll() async {
    await _preferences.clear();

    nickName =
        ValueNotifier(_preferences.getString('nick_name'));
    violetModeOn =
        ValueNotifier(_preferences.getBool('violet_mode') ?? false);
    gameSize =
        ValueNotifier(_preferences.getInt('game_size') ?? 0);
    chatID =
        ValueNotifier(_preferences.getString('chat_id'));
  }
}
