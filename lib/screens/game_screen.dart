import 'package:flutter/material.dart';

import '../widgets/secret_button.dart';

class GameScreen extends StatelessWidget {
  final int gameSize;

  const GameScreen({Key? key, this.gameSize = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Naše supr hra'),
        elevation: 0,
      ),
      floatingActionButton: const SecretButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
