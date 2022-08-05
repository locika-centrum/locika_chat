import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_status.dart';
import '../game/game_move.dart';

class GameScoreWidget extends StatelessWidget {
  const GameScoreWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
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
        Column(
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
}
