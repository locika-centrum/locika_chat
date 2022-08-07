import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../../models/app_settings_data.dart';
import '../../../providers/app_settings.dart';
import './game_move.dart';

Logger _log = Logger('TicTacToe GameStatus');

class GameStatus with ChangeNotifier {
  late int _gameSize;
  int _moveCount = 0;
  List<int> _actualScore = [2, 2];
  GameMove? _lastMove = null;
  late ReversiScore _score;

  GameStatus(int gameSize) {
    _gameSize = gameSize;
    _score = AppSettings().data.getReversiScore(_gameSize);
  }

  ReversiScore get score => _score;
  List<int> get actualScore => _actualScore;

  int get moveCount => _moveCount;
  GameMove? get lastMove => _lastMove;

  void move(GameMove move, List<int> boardScore) {
    _moveCount++;
    _lastMove = move;
    _actualScore[0] = boardScore[0];
    _actualScore[1] = boardScore[1];

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

      AppSettings().data.setReversiScore(_gameSize, _score);
    }

    notifyListeners();
  }

  void reset() {
    _moveCount = 0;
    _lastMove = null;
    _actualScore = [2, 2];

    notifyListeners();
  }
}