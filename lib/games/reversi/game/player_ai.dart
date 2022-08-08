import 'dart:math';
import 'package:logging/logging.dart';

import 'game_move.dart';
import 'game_board.dart';
import 'game_move_tuple.dart';

Logger _log = Logger('reversi AIPlayer');

class PlayerAI {
  GameMove? move(GameBoard board) {
    List<GameMove> moves = possibleMoves(board);
    _log.finer(
        'Possible moves: ${moves.length}, Board value: ${board.boardValue}');

    return moves.isEmpty ? null : moves[Random().nextInt(moves.length)];
  }

  int _MinMax(GameBoard board, GameMove move, int depth, int alpha, int beta,
      bool maximizingPlayer) {
    return 0;
  }

  List<GameMove> possibleMoves(GameBoard board) {
    List<GameMove> result = [];

    for (int row = 0; row < board.size; row++) {
      for (int col = 0; col < board.size; col++) {
        if (board.surrounding[row][col] == true) {
          List<GameMoveTuple> moveTuples = board.tuplesChangingColor(
              GameMove(row: row, col: col, symbol: board.activeSymbol));
          if (moveTuples.isNotEmpty)
            result
                .add(GameMove(row: row, col: col, symbol: board.activeSymbol));
        }
      }
    }

    return result;
  }
}
