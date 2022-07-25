import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../game/player_ai.dart';
import '../game/game_board.dart';
import '../models/game_move.dart';

Logger _log = Logger('GameBoard Widget');

class GameBoardWidget extends StatefulWidget {
  final int gameSize;

  GameBoardWidget({int this.gameSize = 0, Key? key}) : super(key: key);

  @override
  State<GameBoardWidget> createState() =>
      _GameBoardWidgetState(GameBoard(size: this.gameSize));
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  final GameBoard gameBoard;
  final PlayerAI playerAI = PlayerAI();
  bool isLocked = false;

  _GameBoardWidgetState(this.gameBoard);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          // color: Theme.of(context).primaryColor,
          width: 2.0,
        ),
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gameBoard.cols,
        ),
        shrinkWrap: true,
        itemCount: gameBoard.rows * gameBoard.cols,
        itemBuilder: _buildBoardItems,
      ),
    );
  }

  Widget _buildBoardItems(BuildContext context, int index) {
    int row, col = 0;
    row = (index / gameBoard.cols).floor();
    col = (index % gameBoard.cols);
    return GestureDetector(
      onTap: () => _gridItemTapped(row, col),
      child: GridTile(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              // color: Theme.of(context).primaryColor,
              width: 0.5,
            ),
          ),
          child: Center(
            child: _buildBoardItem(context, row, col),
          ),
        ),
      ),
    );
  }

  Widget _buildBoardItem(BuildContext context, int row, int col) {
    switch (gameBoard.board[row][col]) {
      case 0:
        return LayoutBuilder(builder: (context, constraint) {
          return Icon(
            Icons.panorama_fish_eye,
            color: Colors.blue,
            size: constraint.biggest.height,
          );
        });
      case 1:
        return LayoutBuilder(builder: (context, constraint) {
          return Icon(
            Icons.close,
            color: Colors.red,
            size: constraint.biggest.height,
          );
        });
      default:
        return Container();
    }
  }

  void _gridItemTapped(int row, int col) {
    _log.finest('IS LOCKED: ${isLocked}');
    if (!isLocked) {
      isLocked = true;

      for (int player = 0; player <= 1; player++) {
        GameMove? move = (player == 0)
            ? gameBoard.recordCoordinates(row, col)
            : gameBoard.recordMove(playerAI.move(gameBoard));

        if (move != null) {
          _log.fine('BEST MOVE = ${move}');
          setState(() {});

          if (gameBoard.winSymbol != null) {
            // Move was winning move
            _log.finest('*** VICTORY ***');
            return;
          } else {
            if (gameBoard.availableMoves == 0) {
              // No further moves are possible
              _log.finest('*** DRAW ***');
              return;
            }
          }
        }
      }
      isLocked = false;
    }
  }
}
