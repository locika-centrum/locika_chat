import 'package:flutter/material.dart';

class GameNavigationBar extends StatefulWidget {
  final Function onMenuChange;

  GameNavigationBar(this.onMenuChange, {Key? key}) : super(key: key);

  @override
  State<GameNavigationBar> createState() => _GameNavigationBarState();
}

class _GameNavigationBarState extends State<GameNavigationBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      currentIndex: _currentIndex,
      onTap: _onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.videogame_asset_outlined), label: 'Piškvorky'),
        BottomNavigationBarItem(icon: Icon(Icons.videogame_asset_outlined), label: 'Puzzle',),
        BottomNavigationBarItem(icon: Icon(Icons.videogame_asset_outlined), label: 'Něco bude',),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Nastavení',),
      ],
    );
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onMenuChange(index);
  }
}
