import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class TicTacToeScore {
  int noOfWins;
  int noOfLosses;
  int noOfGames;

  TicTacToeScore(this.noOfWins, this.noOfLosses, this.noOfGames);

  List<String> toStringList() => [noOfWins.toString(), noOfLosses.toString(), noOfGames.toString()];

  @override
  String toString() {
    return '[${noOfWins}, ${noOfLosses}, ${noOfGames}]';
  }
}

class SlidingScore {
  int noOfMoves;
  int noOfGames;

  SlidingScore(this.noOfMoves, this.noOfGames);

  List<String> toStringList() => [noOfMoves.toString(), noOfGames.toString()];

  @override
  String toString() {
    return '[${noOfMoves}, ${noOfGames}]';
  }
}

class AppSettingsData {
  SharedPreferences preferences;

  static const List<Map> _optionPreferences = [
    {
      'key': 'age_category',
      'values': [
        {'category': 'dítě', 'title': 'Lehká', 'subtitle': 'vhodné pro děti'},
        {
          'category': 'teenager',
          'title': 'Základní',
          'subtitle': 'vhodné pro školáky'
        },
        {
          'category': 'student',
          'title': 'Střední',
          'subtitle': 'vhodné pro studenty'
        },
        {
          'category': 'dospělý',
          'title': 'Expert',
          'subtitle': 'vhodné pro dospělé'
        },
      ],
    },
    {
      'key': 'game_size',
      'values': ['malá', 'střední', 'velká', 'největší'],
    },
  ];

  // Generic parameters
  int? _ageCategory;
  late bool _violetModeOn;
  late bool _showVioletModeInfo;

  // Game parameters
  late int _gameSize;
  List _tictactoeScores = [null, null, null, null];
  List _slidingScores = [null, null, null, null];

  // Chat parameters
  String? _nickName;
  String? _chatID;
  Cookie? _cookie;

  AppSettingsData(this.preferences) {
    _refreshData();
  }

  void _refreshData() {
    _ageCategory = preferences.getInt('age_category');
    _violetModeOn = preferences.getBool('violet_mode') ?? false;
    _showVioletModeInfo = preferences.getBool('violet_mode_info') ?? false;
    _gameSize = preferences.getInt('game_size') ?? 0;

    _nickName = preferences.getString('nick_name');
    _chatID = preferences.getString('chat_id');
    if (preferences.containsKey('cookie')) {
      _cookie = Cookie.fromSetCookieValue(preferences.getString('cookie')!);
    }

    // Scores per game
    List? score;
    for (int i = 0; i < gameSizes.length; i++) {
      score = preferences.getStringList('tictactoe_${i}');
      if (score != null && score.length == 3) {
        _tictactoeScores[i] = TicTacToeScore(
            int.parse(score[0]), int.parse(score[1]), int.parse(score[2]));
      } else {
        _tictactoeScores[i] = null;
      }

      score = preferences.getStringList('sliding_${i}');
      if (score != null && score.length == 2) {
        _slidingScores[i] =
            SlidingScore(int.parse(score[0]), int.parse(score[1]));
      } else {
        _slidingScores[i] = null;
      }
    }
  }

  // Getters
  int? get ageCategory => _ageCategory;
  int get gameSize => _gameSize;
  bool get violetModeOn => _violetModeOn;
  bool get showVioletModeInfo => _showVioletModeInfo;
  String? get nickName => _nickName;
  String? get chatID => _chatID;
  Cookie? get cookie => _cookie;

  List<Map> get ageCategories => _optionPreferences
      .singleWhere((element) => element['key'] == 'age_category')['values'];
  List<String> get gameSizes => _optionPreferences
      .singleWhere((element) => element['key'] == 'game_size')['values'];

  TicTacToeScore getTicTacToeScore(int gameSize) =>
      _tictactoeScores[gameSize] ?? TicTacToeScore(0, 0, 0);
  SlidingScore getSlidingScore(int gameSize) =>
      _slidingScores[gameSize] ?? SlidingScore(0, 0);

  void setTicTacToeScore(int gameSize, TicTacToeScore score) {
    _tictactoeScores[gameSize] = score;
    preferences.setStringList('tictactoe_${gameSize}', score.toStringList());
  }

  void setSlidingScore(int gameSize, SlidingScore score) {
    _slidingScores[gameSize] = score;
    preferences.setStringList('sliding_${gameSize}', score.toStringList());
  }

  // Setters
  void setAgeCategory(int ageCategory) {
    _ageCategory = ageCategory;
    preferences.setInt('age_category', _ageCategory!);
  }

  void setGameSize(int gameSize) {
    _gameSize = gameSize;
    preferences.setInt('game_size', _gameSize);
  }

  void toggleVioletMode() {
    _violetModeOn = !_violetModeOn;
    _showVioletModeInfo = _violetModeOn;

    preferences.setBool('violet_mode', _violetModeOn);
    preferences.setBool('violet_mode_info', _showVioletModeInfo);
  }

  void toggleVioletModeInfo() {
    _showVioletModeInfo = !_showVioletModeInfo;
    preferences.setBool('violet_mode_info', _showVioletModeInfo);
  }

  void setNickName(String? nickName) {
    _nickName = nickName;
    nickName == null
        ? preferences.remove('nick_name')
        : preferences.setString('nick_name', nickName);
  }

  void setChatID(String? id) {
    _chatID = id;
    id == null
        ? preferences.remove('chat_id')
        : preferences.setString('chat_id', id);
  }

  void setCookie(Cookie? cookie) {
    _cookie = cookie;
    cookie == null
        ? preferences.remove('cookie')
        : preferences.setString('cookie', cookie.toString());
  }

  // Other methods
  bool get isEligibleForVioletMode => ageCategory! <= ageCategories.length - 1;

  Future<void> resetScore() async {
    for (int i = 0; i < gameSizes.length; i++) {
      preferences.remove('tictactoe_${i}');
      preferences.remove('sliding_${i}');
    }
    _refreshData();
  }

  Future<void> resetAll() async {
    await preferences.clear();
    _refreshData();
  }

  @override
  String toString() {
    return '{'
        'age_category = ${_ageCategory}, '
        'game_size = ${_gameSize}, '
        'violet_mode = ${_violetModeOn}, '
        'violet_mode = ${_showVioletModeInfo}, '
        'nick_name = ${_nickName}, '
        'chat_id = ${_chatID}, '
        'cookie = ${_cookie}, '
        'tictactoe = ${_tictactoeScores}, '
        'sliding = ${_slidingScores}'
        '}';
  }
}
