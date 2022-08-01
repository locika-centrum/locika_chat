import 'dart:math';
import 'package:logging/logging.dart';

import './game_move.dart';
import './game_move_tuple.dart';

Logger _log = Logger('GameBoard - tictactoe');

const WIN = 200000;

const List<List<int>> tupleEval = [
  [], // not applicable
  [], // not applicable
  [0, 1, 1751, WIN], // three in row
  [0, 1, 511, 1751, WIN], // four in row
  [0, 1, 73, 511, 1751, WIN], // five in row
];

class GameBoard {
  final int size;
  late List<List<int?>> _board;
  late List<List<bool>> _surrounding;
  late int _symbol;
  late int _winSequenceLength;
  late int _rows, _cols;
  late int _availableMoves;
  int? _winSymbol;

  List<List<int?>> get board => this._board;
  List<List<bool>> get surrounding => this._surrounding;
  int get rows => this._rows;
  int get cols => this._cols;
  int get activeSymbol => this._symbol;
  int get availableMoves => this._availableMoves;
  int get winSequenceLength => this._winSequenceLength;
  int? get winSymbol => this._winSymbol;

  GameBoard({required int this.size, int? startSymbol}) {
    this._symbol = startSymbol ?? Random().nextInt(1);
    switch (this.size) {
      case 1:
        this._rows = this._cols = 5;
        this._winSequenceLength = 4;
        break;
      case 2:
        this._rows = this._cols = 10;
        this._winSequenceLength = 5;
        break;
      case 3:
        this._rows = 15;
        this._cols = 12;
        this._winSequenceLength = 5;
        break;
      default:
        this._rows = this._cols = 3;
        this._winSequenceLength = 3;
    }
    this._board = List.generate(
      this._rows,
      (index) => List.generate(
        this._cols,
        (index) => null,
        growable: false,
      ),
      growable: false,
    );
    this._surrounding = List.generate(
      this._rows,
      (index) => List.generate(
        this._cols,
        (index) => false,
        growable: false,
      ),
      growable: false,
    );
    this._availableMoves = this._rows * this._cols;
  }

  GameMove? recordCoordinates(int row, int col, {bool ownMove = true}) {
    GameMove? result;

    if (this._board[row][col] == null) {
      result = GameMove(row: row, col: col, symbol: this._symbol);

      this._board[row][col] = this._symbol;
      this._symbol = 1 - this._symbol;
      this._availableMoves--;

      int diameter = (this._winSequenceLength / 2).floor();
      for (int i = -diameter; i <= diameter; i++) {
        for (int j = -diameter; j <= diameter; j++) {
          if (row + i >= 0 && row + i < _rows && col + j >= 0 && col + j < _cols)
            this._surrounding[row + i][col + j] = true;
        }
      }

      result.value = _evaluateMove(result, ownMove);
      if (result.value >= WIN) this._winSymbol = 1 - this._symbol;
    }
    return result;
  }

  GameMove? recordMove(GameMove? move, {bool ownMove = true}) {
    return (move == null)
        ? null
        : recordCoordinates(move.row, move.col, ownMove: ownMove);
  }

  GameBoard clone() {
    GameBoard result = GameBoard(size: this.size, startSymbol: this._symbol);
    for (int row = 0; row < result._rows; row++) {
      for (int col = 0; col < result._cols; col++) {
        result._board[row][col] = this._board[row][col];
        result._surrounding[row][col] = this._surrounding[row][col];
      }
    }
    result._availableMoves = this._availableMoves;

    return result;
  }

  int _evaluateMove(GameMove move, bool ownMove) {
    List<GameMoveTuple> listOfTuples = _tuplesToEvaluate(move);

    int moveValue = 0;
    for (GameMoveTuple tuple in listOfTuples) {
      if (!tuple.bothSymbols) {
        moveValue += tupleEval[this._winSequenceLength - 1]
            [tuple.symbolCount[move.symbol!]];
      }
      // TODO perhaps I need to compare the original value - we will see ;)
    }
    return ownMove ? moveValue : -1 * moveValue;
  }

  List<GameMoveTuple> _tuplesToEvaluate(GameMove move) {
    List<GameMoveTuple> result = [];
    int winSequenceLength = this._winSequenceLength;

    // horizontal
    for (int i = 0; i < winSequenceLength; i++) {
      if (move.col + i - (winSequenceLength - 1) >= 0 &&
          move.col + i < this._cols) {
        GameMoveTuple tuple = GameMoveTuple();
        for (int j = 0; j < winSequenceLength; j++)
          tuple.add(GameMove(
            row: move.row,
            col: move.col + i - (winSequenceLength - 1) + j,
            symbol: this._board[move.row]
                [move.col + i - (winSequenceLength - 1) + j],
          ));
        result.add(tuple);
      }
    }

    // vertical
    for (int i = 0; i < winSequenceLength; i++) {
      if (move.row + i - (winSequenceLength - 1) >= 0 &&
          move.row + i < this._rows) {
        GameMoveTuple tuple = GameMoveTuple();
        for (int j = 0; j < winSequenceLength; j++)
          tuple.add(GameMove(
            row: move.row + i - (winSequenceLength - 1) + j,
            col: move.col,
            symbol: this._board[move.row + i - (winSequenceLength - 1) + j]
                [move.col],
          ));
        result.add(tuple);
      }
    }

    // diagonal left_up-right_down
    for (int i = 0; i < winSequenceLength; i++) {
      if (move.row + i - (winSequenceLength - 1) >= 0 &&
          move.col + i - (winSequenceLength - 1) >= 0 &&
          move.row + i < this._rows &&
          move.col + i < this._cols) {
        GameMoveTuple tuple = GameMoveTuple();
        for (int j = 0; j < winSequenceLength; j++)
          tuple.add(GameMove(
            row: move.row + i - (winSequenceLength - 1) + j,
            col: move.col + i - (winSequenceLength - 1) + j,
            symbol: this._board[move.row + i - (winSequenceLength - 1) + j]
                [move.col + i - (winSequenceLength - 1) + j],
          ));
        result.add(tuple);
      }
    }

    // diagonal right_up-left_down
    for (int i = 0; i < winSequenceLength; i++) {
      if (move.row - i + (winSequenceLength - 1) < this._rows &&
          move.col + i - (winSequenceLength - 1) >= 0 &&
          move.row - i >= 0 &&
          move.col + i < this._cols) {
        //OK
        GameMoveTuple tuple = GameMoveTuple();
        for (int j = 0; j < winSequenceLength; j++)
          tuple.add(GameMove(
            row: move.row - i + (winSequenceLength - 1) - j,
            col: move.col + i - (winSequenceLength - 1) + j,
            symbol: this._board[move.row - i + (winSequenceLength - 1) - j]
                [move.col + i - (winSequenceLength - 1) + j],
          ));
        result.add(tuple);
      }
    }

    return result;
  }
}
