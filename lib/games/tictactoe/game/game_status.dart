import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import './game_move.dart';
import '../../../providers/app_settings.dart';
import '../../../models/app_settings_data.dart';

Logger _log = Logger('TicTacToe GameStatus');

class GameStatus with ChangeNotifier {
  late int _gameSize;
  int _moveCount = 0;
  GameMove? _lastMove = null;
  late TicTacToeScore _score;

  GameStatus(int gameSize) {
    _gameSize = gameSize;
    _score = AppSettings().data.getTicTacToeScore(_gameSize);
  }

  TicTacToeScore get score => _score;

  int get moveCount => _moveCount;
  GameMove? get lastMove => _lastMove;

  void move(GameMove move) {
    _moveCount++;
    _lastMove = move;
    if (move.winningMove != null) {
      _score.noOfGames++;

      _log.info(
          'Game over: ${_gameSize} > (${_moveCount}, ${move.winningMove == 0 ? "DRAW" : (move.winningMove == 1 ? "WIN" : "LOST")}) > ${_score}');
      switch (move.winningMove) {
        case 1:
          _score.noOfWins++;
          break;
        case -1:
          _score.noOfLosses++;
          break;
      }

      AppSettings().data.setTicTacToeScore(_gameSize, _score);
    }

    notifyListeners();
  }

  void reset() {
    _moveCount = 0;
    _lastMove = null;

    notifyListeners();
  }
}
