import 'dart:async';
import 'package:flutter/material.dart';

import '../providers/app_settings.dart';
import '../widgets/game_navigation_bar.dart';
import '../widgets/secret_button.dart';
import '../games/tictactoe/tictactoe_screen.dart';
import '../games/sliding/sliding_screen.dart';
import '../games/reversi/reversi_screen.dart';
import './settings_screen.dart';
import '../widgets/how_it_works_dialog.dart';

// Delay in seconds
const DELAYED_HOW_TO = 30;

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Widget _page;
  late String _title;
  Timer? _howToTimer = null;

  @override
  void initState() {
    _onMenuChange(0);

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
    setState(() {
      if (_howToTimer != null) _howToTimer?.cancel();

      switch (index) {
        case 1:
          _page = SlidingPuzzleScreen(gameSize: AppSettings().data.gameSize,);
          _title = 'Puzzle';
          _howToTimer = _setHowToTimer();
          break;
        case 2:
          _page = ReversiScreen(gameSize: AppSettings().data.gameSize,);
          _title = 'Reversi';
          _howToTimer = _setHowToTimer();
          break;
        case 3:
          _page = SettingsScreen();
          _title = 'Nastavení';
          break;
        default:
          _page = TicTacToeScreen(gameSize: AppSettings().data.gameSize,);
          _title = 'Piškvorky';
          _howToTimer = _setHowToTimer();
      }
    });
  }

  Timer? _setHowToTimer() {
    if (AppSettings().data.showVioletModeInfo) {
      return Timer(const Duration(seconds: DELAYED_HOW_TO), () {
        showModalBottomSheet(context: context, builder: (_) {
          return HowItWorksDialog();
        },);
      });
    }
    return null;
  }
}
