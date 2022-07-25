import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:locika_game_test/widgets/game_board_widget.dart';
import 'package:locika_game_test/widgets/game_score_widget.dart';

import '../widgets/secret_button.dart';

class GameScreen extends StatelessWidget {
  final bool secretEnabled;
  final int gameSize;

  GameScreen({
    this.gameSize = 0,
    this.secretEnabled = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Naše supr hra'),
        elevation: 0,
      ),
      floatingActionButton: secretEnabled ? const SecretButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Column(
        children: [
          GameBoardWidget(gameSize: this.gameSize),
          const Spacer(),
          GameScoreWidget(),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: SafeArea(child: Text('')),
    );
  }
}
