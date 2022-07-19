import 'package:flutter/material.dart';

import '../providers/app_settings.dart';
import '../widgets/secret_button.dart';

class GameScreen extends StatelessWidget {
  final int gameSize;
  final bool secretEnabled =
      AppSettings.violetModeOn.value && AppSettings.isEligibleForVioletMode();

  GameScreen({Key? key, this.gameSize = 0}) : super(key: key);

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
    );
  }
}
