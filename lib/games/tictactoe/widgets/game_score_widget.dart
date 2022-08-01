import 'package:flutter/material.dart';

class GameScoreWidget extends StatelessWidget {
  final int scorePlayer;
  final int scoreOpponent;
  final String message;

  const GameScoreWidget({
    this.scorePlayer = 0,
    this.scoreOpponent = 0,
    this.message = '',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '${this.scorePlayer} : ${this.scoreOpponent}',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}