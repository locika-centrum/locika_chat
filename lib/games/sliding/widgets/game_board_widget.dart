import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

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

  @override
  void didChangeDependencies() {
    // Reset if the lastMove has been wiped
    if (Provider.of<GameStatus>(context).lastMove == null) {
      gameBoard = GameBoard(settingsSize: widget.gameSize);
      _isLocked = gameBoard.evaluateBoard();
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

        return Text(
          gameBoard.board[row][col].toString(),
          style: TextStyle(fontSize: constraint.maxHeight / 2),
        );
      }),
    );
  }

  void _gridItemTapped(int row, int col) {
    if (!_isLocked) {
      GameMove? move = gameBoard.recordCoordinates(row, col);
      _log.finest(
          'Tapped: (${row}, ${col}) - ${move == null ? 'in' : ''}valid move');

      if (move != null) {
        _isLocked = gameBoard.evaluateBoard();
        move.winningMove = _isLocked;
        context.read<GameStatus>().move(move);

        setState(() {});
      }
    }
  }
}
