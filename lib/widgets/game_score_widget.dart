import 'package:flutter/material.dart';

class GameScoreWidget extends StatefulWidget {
  const GameScoreWidget({Key? key}) : super(key: key);

  @override
  State<GameScoreWidget> createState() => _GameScoreWidgetState();
}

class _GameScoreWidgetState extends State<GameScoreWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('${0} : ${0}', style: Theme.of(context).textTheme.headlineMedium,);
  }
}
