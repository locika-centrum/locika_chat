import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './game/game_status.dart';
import './widgets/game_board_widget.dart';
import './widgets/game_score_widget.dart';

class SlidingPuzzleScreen extends StatelessWidget {
  final int gameSize;

  const SlidingPuzzleScreen({this.gameSize = 0, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameStatus(this.gameSize)),
        ],
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: GameBoardWidget(gameSize: this.gameSize),
            ),
            Expanded(
              child: GameScoreWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
