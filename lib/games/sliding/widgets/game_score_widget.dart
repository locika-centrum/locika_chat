import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_status.dart';

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
            Text('P O Č E T'),
            Text('T A H Ů'),
            SizedBox(height: 8),
            Text(
              '${context.select<GameStatus, int>((model) => model.moveCount)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('N E J M É N Ě'),
            Text('T A H Ů'),
            SizedBox(height: 8),
            Text(
              '${context.read<GameStatus>().score.noOfMoves == 0 ? "-" : context.read<GameStatus>().score.noOfMoves}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              iconSize: 50,
              onPressed: (context.read<GameStatus>().lastMove != null &&
                      context.read<GameStatus>().lastMove!.winningMove)
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