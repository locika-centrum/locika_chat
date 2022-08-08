import 'dart:math';
import 'package:logging/logging.dart';

import 'game_move.dart';
import 'game_board.dart';

const INT_INFINITY = 999999;
const WIN = 200000;
const MIN_DEPTH = 2;
const MAX_DEPTH = 3;

Logger _log = Logger('tictactoe AIPlayer');

class PlayerAI {
  GameMove? move(GameBoard board) {
    List<GameMove> bestMoves = [];
    int bestMoveValue = -INT_INFINITY;
    DateTime start = DateTime.now();
    DateTime interim1 = start, interim2;
    GameMove? result;

    List<GameMove> possibleMoves = _possibleMoves(board);
    _log.finer(
        'Possible moves: ${possibleMoves.length}, Board value: ${board.boardValue}');
    for (GameMove move in possibleMoves) {
      GameBoard newBoard = board.clone();
      GameMove? newMove = newBoard.recordMove(move, true);
      int moveValue = _MinMax(
          newBoard,
          newMove!,
          possibleMoves.length > 25 ? MIN_DEPTH : MAX_DEPTH,
          -INT_INFINITY,
          INT_INFINITY,
          false);
      if (moveValue > bestMoveValue) {
        bestMoves.clear();
        bestMoveValue = moveValue;
        bestMoves.add(newMove);
      }
    }

    result = bestMoves.length == 0
        ? null
        : bestMoves[Random().nextInt(bestMoves.length)];
    _log.fine(
        'move (${result}) out of ${bestMoves.length} available moves selected in ${DateTime.now().difference(start).inMilliseconds} ms');
    return bestMoves.length == 0
        ? null
        : bestMoves[Random().nextInt(bestMoves.length)];
  }

  int _MinMax(GameBoard board, GameMove move, int depth, int alpha, int beta,
      bool maximizingPlayer) {
    // _log.finest(
    //    '${List.filled(2 * (3 - depth), " ").join()}MOVE: ${move}, BOARD VALUE: ${board.boardValue}, WINNER: ${board.winSymbol}');

    if (depth == 0 || move.value.abs() >= WIN || board.availableMoves == 0) {
      return move.value;
    }

    if (maximizingPlayer) {
      int bestMoveValue = -INT_INFINITY;
      for (GameMove move in _possibleMoves(board)) {
        GameBoard newBoard = board.clone();
        GameMove? newMove = newBoard.recordMove(move, true);
        bestMoveValue = max(bestMoveValue,
            _MinMax(newBoard, newMove!, depth - 1, alpha, beta, false));
        alpha = max(alpha, bestMoveValue);

        if (alpha >= beta) break;
      }

      return bestMoveValue;
    } else {
      int bestMoveValue = INT_INFINITY;
      for (GameMove move in _possibleMoves(board)) {
        GameBoard newBoard = board.clone();
        GameMove? newMove = newBoard.recordMove(move, false);
        bestMoveValue = min(bestMoveValue,
            _MinMax(newBoard, newMove!, depth - 1, alpha, beta, true));
        beta = min(beta, bestMoveValue);

        if (beta <= alpha) break;
      }

      return bestMoveValue;
    }
  }

  List<GameMove> _possibleMoves(GameBoard board) {
    List<GameMove> result = [];

    for (int row = 0; row < board.rows; row++) {
      for (int col = 0; col < board.cols; col++) {
        if (board.surrounding[row][col]) {
          if (board.board[row][col] == null) {
            result
                .add(GameMove(row: row, col: col, symbol: board.activeSymbol));
          }
        }
      }
    }

    return result;
  }
}
