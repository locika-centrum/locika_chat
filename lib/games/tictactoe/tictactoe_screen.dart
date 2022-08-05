import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './game/game_status.dart';
import './widgets/game_board_widget.dart';
import './widgets/game_score_widget.dart';

class TicTacToeScreen extends StatelessWidget {
  final int gameSize;

  TicTacToeScreen({this.gameSize = 0, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameStatus(this.gameSize))
        ],
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: GameBoardWidget(gameSize: this.gameSize,),
            ),
            Expanded(
              child: GameScoreWidget(),
            )
          ],
        ),
      ),
    );
  }

/*
      body: Column(
        children: [
          Expanded(
            child: GameScoreWidget(),
          )
        ],
      ),
    );
  }
 */

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GameBoardWidget(
              gameSize: this.widget.gameSize,
              changeScore: changeScore,
            ),
          ),
          Expanded(
            child: GameScoreWidget(
              scorePlayer: _score.noOfWins,
              scoreOpponent: _score.noOfLosses,
              totalGames: _score.noOfGames,
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
 */
}
