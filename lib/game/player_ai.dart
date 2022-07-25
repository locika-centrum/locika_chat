import 'dart:math';
import 'package:logging/logging.dart';

import '../models/game_move.dart';
import '../models/game_move_tuple.dart';
import './game_board.dart';

const INT_INFINITY = 999999;
const WIN = 200000;
const MIN_MAX_DEPTH = 1;

const List<List<int>> tupleEval = [
  [], // not applicable
  [], // not applicable
  [0, 1, 1751, WIN], // three in row
  [0, 1, 73, 1751, WIN], // four in row
  [0, 1, 73, 511, 1751, WIN], // five in row
];

Logger _log = Logger('AIPlayer');

class PlayerAI {
  GameMove? move(GameBoard board) {
    List<GameMove> bestMoves = [];
    int bestMoveValue = -INT_INFINITY;

    for (GameMove move in _possibleMoves(board)) {
      GameBoard newBoard = board.clone();
      newBoard.recordMove(move);
      int moveValue = _MinMax(newBoard, move, MIN_MAX_DEPTH, -INT_INFINITY, INT_INFINITY, false);
      if (moveValue > bestMoveValue) {
        bestMoves.clear();
        bestMoveValue = moveValue;
        move.value = moveValue;
        bestMoves.add(move);
      }
    }

    return bestMoves.length == 0 ? null : bestMoves[Random().nextInt(bestMoves.length)];
  }

  int _MinMax(GameBoard board, GameMove move, int depth, int alpha, int beta, bool maximizingPlayer) {
    int moveValue = _evaluateMove(board, move, !maximizingPlayer);
    _log.finest(
        'MinMax${List.filled(2 * (3 - depth), " ").join()} - ${board.board} / ${move} -> ${moveValue}');

    if (depth == 0 || moveValue.abs() >= WIN || board.availableMoves == 0) {
      return moveValue;
    }

    if (maximizingPlayer) {
      int bestMoveValue = -INT_INFINITY;
      for (GameMove move in _possibleMoves(board)) {
        GameBoard newBoard = board.clone();
        newBoard.recordMove(move);
        bestMoveValue = max(bestMoveValue, _MinMax(newBoard, move, depth - 1, alpha, beta, false));
        alpha = max(alpha, bestMoveValue);

        if (alpha >= beta) break;
      }

      return bestMoveValue;
    } else {
      int bestMoveValue = INT_INFINITY;
      for (GameMove move in _possibleMoves(board)) {
        GameBoard newBoard = board.clone();
        newBoard.recordMove(move);
        bestMoveValue = min(bestMoveValue, _MinMax(newBoard, move, depth - 1, alpha, beta, true));
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
        if (board.board[row][col] == null) {
          result.add(GameMove(row: row, col: col, symbol: board.activeSymbol));
        }
      }
    }

    return result;
  }

  int _evaluateMove(GameBoard board, GameMove move, bool ownMove) {
    List<GameMoveTuple> listOfTuples = _tuplesToEvaluate(board, move);

    int moveValue = 0;
    for (GameMoveTuple tuple in listOfTuples) {
      if (!tuple.bothSymbols) {
        moveValue += tupleEval[board.winSequenceLength - 1]
        [tuple.symbolCount[move.symbol!]];
      }
      // TODO perhaps I need to compare the original value - we will see ;)
    }
    return ownMove ? moveValue : -1 * moveValue;
  }

  List<GameMoveTuple> _tuplesToEvaluate(GameBoard board, GameMove move) {
    List<GameMoveTuple> result = [];
    int winSequenceLength = board.winSequenceLength;

    // horizontal
    for (int i = 0; i < winSequenceLength; i++) {
      if (move.col + i - (winSequenceLength - 1) >= 0 &&
          move.col + i < board.cols) {
        GameMoveTuple tuple = GameMoveTuple();
        for (int j = 0; j < winSequenceLength; j++)
          tuple.add(GameMove(
            row: move.row,
            col: move.col + i - (winSequenceLength - 1) + j,
            symbol: board.board[move.row]
            [move.col + i - (winSequenceLength - 1) + j],
          ));
        result.add(tuple);
      }
    }

    // vertical
    for (int i = 0; i < winSequenceLength; i++) {
      if (move.row + i - (winSequenceLength - 1) >= 0 &&
          move.row + i < board.rows) {
        GameMoveTuple tuple = GameMoveTuple();
        for (int j = 0; j < winSequenceLength; j++)
          tuple.add(GameMove(
            row: move.row + i - (winSequenceLength - 1) + j,
            col: move.col,
            symbol: board.board[move.row + i - (winSequenceLength - 1) + j]
            [move.col],
          ));
        result.add(tuple);
      }
    }

    // diagonal left_up-right_down
    for (int i = 0; i < winSequenceLength; i++) {
      if (move.row + i - (winSequenceLength - 1) >= 0 &&
          move.col + i - (winSequenceLength - 1) >= 0 &&
          move.row + i < board.rows &&
          move.col + i < board.cols) {
        GameMoveTuple tuple = GameMoveTuple();
        for (int j = 0; j < winSequenceLength; j++)
          tuple.add(GameMove(
            row: move.row + i - (winSequenceLength - 1) + j,
            col: move.col + i - (winSequenceLength - 1) + j,
            symbol: board.board[move.row + i - (winSequenceLength - 1) + j]
            [move.col + i - (winSequenceLength - 1) + j],
          ));
        result.add(tuple);
      }
    }

    // diagonal right_up-left_down
    for (int i = 0; i < winSequenceLength; i++) {
      if (move.row - i + (winSequenceLength - 1) < board.rows &&
          move.col + i - (winSequenceLength - 1) >= 0 &&
          move.row - i >= 0 &&
          move.col + i < board.cols) {
        //OK
        GameMoveTuple tuple = GameMoveTuple();
        for (int j = 0; j < winSequenceLength; j++)
          tuple.add(GameMove(
            row: move.row - i + (winSequenceLength - 1) - j,
            col: move.col + i - (winSequenceLength - 1) + j,
            symbol: board.board[move.row - i + (winSequenceLength - 1) - j]
            [move.col + i - (winSequenceLength - 1) + j],
          ));
        result.add(tuple);
      }
    }

    return result;
  }
}