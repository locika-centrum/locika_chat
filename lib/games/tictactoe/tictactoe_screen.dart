import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../providers/app_settings.dart';
import '../../models/app_settings_data.dart';
import './widgets/game_board_widget.dart';
import './widgets/game_score_widget.dart';

Logger _log = Logger('GameScreen');

class TicTacToeScreen extends StatefulWidget {
  final int gameSize;

  TicTacToeScreen({
    this.gameSize = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  // Wins / Loses / Number of games
  late TicTacToeScore _score;

  @override
  void initState() {
    _score = AppSettings().data.getTicTacToeScore(widget.gameSize);
    _log.finest(
        'Game Statistics: (${this._score.noOfWins}, ${this._score.noOfLosses}, ${this._score.noOfGames})');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: GameBoardWidget(
              gameSize: this.widget.gameSize,
              changeScore: changeScore,
            ),
          ),
          Expanded(
            child: GameScoreWidget(
              scorePlayer: _score.noOfWins,
              scoreOpponent: _score.noOfLosses,
            ),
          )
        ],
      ),
    );
  }

  // Increase score
  // -1 ... loss
  //  0 ... draw
  //  1 ... win
  void changeScore(int status) {
    switch (status) {
      case -1:
        _score.noOfLosses++;
        _score.noOfGames++;
        break;
      case 0:
        _score.noOfGames++;
        break;
      case 1:
        _score.noOfWins++;
        _score.noOfGames++;
        break;
    }
    AppSettings().data.setTicTacToeScore(widget.gameSize, _score);
    setState(() {});
  }
}
