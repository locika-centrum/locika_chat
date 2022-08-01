import 'package:flutter/material.dart';

class GameScoreWidget extends StatelessWidget {
  final int movesPlayer;

  const GameScoreWidget({this.movesPlayer = 0, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '${this.movesPlayer}',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
