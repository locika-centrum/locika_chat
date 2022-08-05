import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import './game_move.dart';
import '../../../providers/app_settings.dart';
import '../../../models/app_settings_data.dart';

Logger _log = Logger('Sliding GameStatus');

class GameStatus with ChangeNotifier {
  late int _gameSize;
  int _moveCount = 0;
  GameMove? _lastMove = null;
  late SlidingScore _score;

  GameStatus(int gameSize) {
    _gameSize = gameSize;
    _score = AppSettings().data.getSlidingScore(_gameSize);
  }

  SlidingScore get score => _score;

  int get moveCount => _moveCount;
  GameMove? get lastMove => _lastMove;
  bool get winningMove => _lastMove == null ? false : _lastMove!.winningMove;

  void move(GameMove? move) {
    _moveCount++;
    _lastMove = move;
    if (move != null && move.winningMove) {
      _score.noOfGames++;
      _log.info('Game over: ${_gameSize} > (${_moveCount}) > ${_score}');
      if (_score.noOfMoves == 0 || _moveCount < _score.noOfMoves) {
        _score.noOfMoves = _moveCount;
      }

      AppSettings().data.setSlidingScore(_gameSize, _score);
    }

    notifyListeners();
  }

  void reset() {
    _moveCount = 0;
    _lastMove = null;

    notifyListeners();
  }
}