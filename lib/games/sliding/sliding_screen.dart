import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../models/app_settings_data.dart';
import '../../providers/app_settings.dart';
import './widgets/game_board_widget.dart';
import './widgets/game_score_widget.dart';

Logger _log = Logger('SlidingPuzzleScreen');

class SlidingPuzzleScreen extends StatefulWidget {
  final int gameSize;

  const SlidingPuzzleScreen({this.gameSize = 0, Key? key}) : super(key: key);

  @override
  State<SlidingPuzzleScreen> createState() => _SlidingPuzzleScreenState();
}

class _SlidingPuzzleScreenState extends State<SlidingPuzzleScreen> {
  late SlidingScore _score;
  int _actualMoves = 0;

  @override
  void initState() {
    _score = AppSettings().data.getSliding(widget.gameSize);

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
              movesPlayer: _actualMoves,
            ),
          ),
        ],
      ),
    );
  }

  void changeScore(int moves, bool winningMove) {
    _log.finest('Move ${moves} - best is ${_score.noOfMoves} - winning ${winningMove}');
    setState(() {
      _actualMoves = moves;
      if (winningMove) {
        int bestScore = _score.noOfMoves == 0 ? moves : min(_score.noOfMoves, moves);
        AppSettings().data.setSlidingScore(
            widget.gameSize, SlidingScore(bestScore, _score.noOfGames++));
      }
    });
  }
}
