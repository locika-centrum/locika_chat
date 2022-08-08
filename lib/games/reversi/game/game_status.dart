import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../../models/app_settings_data.dart';
import '../../../providers/app_settings.dart';
import './game_move.dart';

Logger _log = Logger('Reversi GameStatus');

class GameStatus with ChangeNotifier {
  late int _gameSize;
  int _moveCount = 0;
  List<int> _actualScore = [2, 2];
  List<bool> _pass = [false, false];
  bool _humanIsPassing = false;
  GameMove? _lastMove = null;
  late ReversiScore _score;

  GameStatus(int gameSize) {
    _gameSize = gameSize;
    _score = AppSettings().data.getReversiScore(_gameSize);
  }

  ReversiScore get score => _score;
  List<int> get actualScore => _actualScore;
  bool get gameOver =>
      (_pass[0] == true && _pass[1] == true) ||
      (_lastMove != null && _lastMove!.lastMove);
  // Human always start - change next if players will swap
  bool get noAvailableMove => _pass[0];
  bool get humanIsPassing => _humanIsPassing;

  int get moveCount => _moveCount;
  GameMove? get lastMove => _lastMove;

  void move(GameMove move, List<int> boardScore) {
    _moveCount++;
    _lastMove = move;
    _actualScore[0] = boardScore[0];
    _actualScore[1] = boardScore[1];
    _pass = [false, false];
    _humanIsPassing = false;

    if (move.lastMove) {
      _log.finest('Move ${move} is the final move = game over');
      _processResult();
    }

      notifyListeners();
  }

  void pass() {
    _log.finest('Human has decided to pass');
    _humanIsPassing = true;

    notifyListeners();
  }

  void cannotMove(int symbol) {
    _pass[symbol] = true;

    if (_pass[0] == _pass[1]) {
      _log.finest('Both players passed = game over');
      _processResult();
    }

    notifyListeners();
  }

  void reset() {
    _moveCount = 0;
    _lastMove = null;
    _actualScore = [2, 2];

    notifyListeners();
  }

  void _processResult() {
    _pass = [false, false];
    _humanIsPassing = false;
    _score.noOfGames++;
    _lastMove?.lastMove = true;

    _log.info(
        'Game over: ${_gameSize} > (${_moveCount}) - ${_actualScore[0] == _actualScore[1] ? "DRAW" : (_actualScore[0] > _actualScore[1] ? "WIN" : "LOST")} > ${_score}');

    if (_actualScore[0] > _actualScore[1]) _score.noOfWins++;
    if (_actualScore[0] < _actualScore[1]) _score.noOfLosses++;

    AppSettings().data.setReversiScore(_gameSize, _score);
  }
}
