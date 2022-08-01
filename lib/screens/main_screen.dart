import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../providers/app_settings.dart';
import '../widgets/game_navigation_bar.dart';
import '../widgets/secret_button.dart';
import '../games/tictactoe/tictactoe_screen.dart';
import '../games/sliding/sliding_screen.dart';
import '../games/unknown/unknown_screen.dart';
import './settings_screen.dart';

Logger _log = Logger('MainScreen');

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Widget _page;
  late String _title;

  @override
  void initState() {
    _page = TicTacToeScreen(gameSize: AppSettings().data.gameSize,);
    _title = 'Piškvorky';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AppSettings().data.violetModeOn &&
              AppSettings().data.isEligibleForVioletMode
          ? const SecretButton()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      appBar: AppBar(
        title: Text(_title),
        elevation: 0,
      ),
      body: _page,
      bottomNavigationBar: GameNavigationBar(_onMenuChange),
    );
  }

  void _onMenuChange(int index) {
    _log.finest('Settings: ${AppSettings().data}');
    setState(() {
      switch (index) {
        case 1:
          _page = SlidingPuzzleScreen(gameSize: AppSettings().data.gameSize,);
          _title = 'Puzzle';
          break;
        case 2:
          _page = UnknownScreen();
          _title = 'Super hra';
          break;
        case 3:
          _page = SettingsScreen();
          _title = 'Nastavení';
          break;
        default:
          _page = TicTacToeScreen(gameSize: AppSettings().data.gameSize,);
          _title = 'Piškvorky';
      }
    });
  }
}
