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
          onTap: () {
            _showAllScores(context);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('A K T U Á L N Í'),
              Text('S T A V'),
              SizedBox(height: 8),
              Text(
                '${context.select<GameStatus, int>((model) => model.actualScore[0])} : ${context.select<GameStatus, int>((model) => model.actualScore[1])}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            _showAllScores(context);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('S C O R E'),
              Text(''),
              SizedBox(height: 8),
              Text(
                '${context.select<GameStatus, int>((model) => model.score.noOfWins)} : ${context.select<GameStatus, int>((model) => model.score.noOfLosses)}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              iconSize: 35,
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
              onPressed: (context
                      .select<GameStatus, bool>((model) => model.gameOver))
                  ? context.read<GameStatus>().reset
                  : null,
              icon: Icon(Icons.refresh),
            ),
            IconButton(
              iconSize: 35,
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 16),
              onPressed: (context.select<GameStatus, bool>(
                      (model) => model.noAvailableMove))
                  ? () {
                      context.read<GameStatus>().pass();
                    }
                  : null,
              icon: Icon(Icons.skip_next),
            ),
          ],
        ),
      ],
    );
  }

  void _showAllScores(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return GameTotalScoreWidget();
        });
  }
}
