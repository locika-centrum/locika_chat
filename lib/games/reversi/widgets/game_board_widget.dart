import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../game/game_board.dart';
import '../game/game_move.dart';
import '../game/game_status.dart';
import '../game/player_ai.dart';

class GameBoardWidget extends StatefulWidget {
  final int gameSize;

  const GameBoardWidget({
    int this.gameSize = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  late GameBoard gameBoard;
  late bool _isLocked;
  final PlayerAI playerAI = PlayerAI();

  @override
  void didChangeDependencies() {
    if (Provider.of<GameStatus>(context).lastMove == null) {
      gameBoard = GameBoard(settingsSize: widget.gameSize);
      _isLocked = false;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: gameBoard.size * gameBoard.size,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gameBoard.size,
        ),
        itemBuilder: _buildBoardItems,
      ),
    );
  }

  Widget _buildBoardItems(BuildContext context, int index) {
    int row = (index / gameBoard.size).floor();
    int col = (index % gameBoard.size);

    return Padding(
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: GestureDetector(
          onTap: () => _gridItemTapped(row, col),
          child: Container(
              color: Theme.of(context).highlightColor,
              child: _buildBoardItem(row, col)),
        ),
      ),
    );
  }

  Widget _buildBoardItem(int row, int col) {
    return Center(
      child: LayoutBuilder(builder: (context, constraint) {
        if (gameBoard.board[row][col] == null) return Container();

        return SvgPicture.asset(gameBoard.board[row][col] == 0
            ? 'assets/images/black.svg'
            : 'assets/images/white.svg',);
      }),
    );
  }

  void _gridItemTapped(int row, int col) {
    if (!_isLocked) {
      _isLocked = true;
      GameMove? move = gameBoard.recordCoordinates(row, col, false);
      if (move != null) {
        setState(() {});

        context.read<GameStatus>().move(move, gameBoard.symbolCount);
      }

      _isLocked = false;
    }
  }
}
