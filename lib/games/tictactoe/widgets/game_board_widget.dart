import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../game/player_ai.dart';
import '../game/game_board.dart';
import '../game/game_move.dart';
import '../game/game_status.dart';

Logger _log = Logger('GameBoard Widget');

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
      gameBoard = GameBoard(size: widget.gameSize);
      _isLocked = false;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: gameBoard.rows * gameBoard.cols,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gameBoard.cols,
        ),
        itemBuilder: _buildBoardItems,
      ),
    );
  }

  Widget _buildBoardItems(BuildContext context, int index) {
    int row = (index / gameBoard.cols).floor();
    int col = (index % gameBoard.cols);

    return Padding(
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: GestureDetector(
          onTap: () => _gridItemTapped(row, col),
          child: Container(
            color: Theme.of(context).highlightColor,
            child: _buildBoardItem(row, col)
          ),
        ),
      ),
    );
  }

  Widget _buildBoardItem(int row, int col) {
    return Center(
      child: LayoutBuilder(builder: (context, constraint) {
        if (gameBoard.board[row][col] == null) return Container();

        return Icon(
          gameBoard.board[row][col] == 0 ? Icons.panorama_fish_eye : Icons.close,
          color: gameBoard.board[row][col] == 0 ? Colors.blue : Colors.red,
          size: constraint.biggest.height,
        );
      }),
    );
  }

  void _gridItemTapped(int row, int col) {
    if (!_isLocked) {
      _isLocked = true;

      for (int player = 0; player <= 1; player++) {
        GameMove? move = (player == 0)
            ? gameBoard.recordCoordinates(row, col)
            : gameBoard.recordMove(playerAI.move(gameBoard));

        if (move != null) {
          _log.finest('Move (${player == 0 ? "human" : "ai"}): ${move}');
          setState(() {});

          if (gameBoard.winSymbol != null) {
            // Move was winning move
            move.winningMove = player == 0 ? 1 : -1;

            context.read<GameStatus>().move(move);
            return;
          } else {
            if (gameBoard.availableMoves == 0) {
              // No further moves are possible
              move.winningMove = 0;

              context.read<GameStatus>().move(move);
              return;
            }
          }
        } else {
          // Human player has selected already occupied cell
          _log.finest('Move (${player == 0 ? "human" : "ai"}): (${row}, ${col}) is not valid');
          break;
        }
      }
      _isLocked = false;
    }
  }
}
