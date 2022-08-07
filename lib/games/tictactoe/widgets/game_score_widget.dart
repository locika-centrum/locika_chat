import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_status.dart';
import '../game/game_move.dart';
import './game_total_score_widget.dart';

class GameScoreWidget extends StatelessWidget {
  const GameScoreWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () { _showAllScores(context); },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(''),
              Text('S C O R E'),
              SizedBox(height: 8),
              Text(
                '${context.select<GameStatus, int>((model) => model.score.noOfWins)} : ${context.select<GameStatus, int>((model) => model.score.noOfLosses)}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () { _showAllScores(context); },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('H E R'),
              Text('C E L K E M'),
              SizedBox(height: 8),
              Text(
                '${context.select<GameStatus, int>((model) => model.score.noOfGames)}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              iconSize: 50,
              onPressed: (context.select<GameStatus, GameMove?>((model) => model.lastMove) != null &&
                  context.read<GameStatus>().lastMove!.winningMove != null)
                  ? context.read<GameStatus>().reset
                  : null,
              icon: Icon(Icons.refresh),
            ),
          ],
        ),
      ],
    );
  }

  void _showAllScores(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) {
      return GameTotalScoreWidget();
    });
  }
}
