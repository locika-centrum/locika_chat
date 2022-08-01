import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../game/game_board.dart';
import '../game/game_move.dart';

Logger _log = Logger('GameBoard Widget');

class GameBoardWidget extends StatefulWidget {
  final int gameSize;
  final Function changeScore;

  const GameBoardWidget({
    int this.gameSize = 0,
    required this.changeScore,
    Key? key,
  }) : super(key: key);

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  late GameBoard gameBoard;
  late bool _isLocked;

  @override
  void initState() {
    gameBoard = GameBoard(settingsSize: widget.gameSize);
    _isLocked = gameBoard.evaluateBoard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _log.finest('Board: ${gameBoard.board}');

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
        widget.changeScore(gameBoard.moves, _isLocked);
        setState(() {});
      }
    }
  }
}
