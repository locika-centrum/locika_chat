import 'package:logging/logging.dart';

import './game_move.dart';
import './game_move_tuple.dart';

Logger _log = Logger('GameBoard - tictactoe');

const WIN = 200000;

const List<List<int>> tupleEval = [
  [], // not applicable
  [], // not applicable
  [0, 1, 1751, WIN], // three in row
  [0, 1, 511, 5000, WIN], // four in row
  [0, 1, 73, 850, 7000, WIN], // five in row
];

class GameBoard {
  final int size;
  late List<List<int?>> _board;
  late List<List<bool>> _surrounding;
  late int _startSymbol;
  late int _symbol;
  late int _winSequenceLength;
  late int _rows, _cols;
  late int _availableMoves;
  int? _winSymbol;
  int _boardValue = 0;

  List<List<int?>> get board => this._board;
  List<List<bool>> get surrounding => this._surrounding;
  int get rows => this._rows;
  int get cols => this._cols;
  int get activeSymbol => this._symbol;
  int get availableMoves => this._availableMoves;
  int get winSequenceLength => this._winSequenceLength;
  int? get winSymbol => this._winSymbol;
  int get boardValue => this._boardValue;

  GameBoard({required int this.size}) {
    this._startSymbol = 1;
    this._symbol = this._startSymbol;
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

  GameMove? recordCoordinates(int row, int col, bool aiPlayer) {
    GameMove? result;

    if (this._board[row][col] == null) {
      this._board[row][col] = this._symbol;

      result = GameMove(row: row, col: col, symbol: this._symbol);
      _evaluateBoard(result);
      result.value = (aiPlayer && this._startSymbol == this._symbol ||
                  !aiPlayer && this._startSymbol != this._symbol
              ? 1
              : -1) *
          this._boardValue;
      this._symbol = 1 - this._symbol;
      this._availableMoves--;

      if (result.value.abs() < WIN) {
        // Record surroundings in the bit map - based on sequence length mark
        // all fields in 8 directions as surrounding for next moves
        int diameter = (this._winSequenceLength / 2).floor();
        for (int i = -diameter; i <= diameter; i++) {
          for (int j = -diameter; j <= diameter; j++) {
            if (row + i >= 0 &&
                row + i < _rows &&
                col + j >= 0 &&
                col + j < _cols &&
                (i == 0 || j == 0 || i.abs() == j.abs()))
              this._surrounding[row + i][col + j] = true;
          }
        }
      }
    }
    return result;
  }

  GameMove? recordMove(GameMove? move, bool aiPlayer) {
    return move == null
        ? null
        : recordCoordinates(move.row, move.col, aiPlayer);
  }

  GameBoard clone() {
    GameBoard result =
        GameBoard(size: this.size);

    // Copy board
    for (int row = 0; row < result._rows; row++) {
      for (int col = 0; col < result._cols; col++) {
        result._board[row][col] = this._board[row][col];
        result._surrounding[row][col] = this._surrounding[row][col];
      }
    }

    // Set additional values
    result._symbol = this._symbol;
    result._availableMoves = this._availableMoves;
    result._boardValue = this._boardValue;

    return result;
  }

  void _evaluateBoard(GameMove lastMove) {
    List<GameMoveTuple> listOfTuples = _tuplesToEvaluate(lastMove);
    int originalValue = 0;
    int moveValue = 0;

    for (GameMoveTuple tuple in listOfTuples) {
      // Before the move there it was a nonzero valuation
      if (tuple.symbolCount[lastMove.symbol!] - 1 == 0 ||
          tuple.symbolCount[1 - lastMove.symbol!] == 0) {
        originalValue += tupleEval[this._winSequenceLength - 1]
                [tuple.symbolCount[lastMove.symbol!] - 1] -
            tupleEval[this._winSequenceLength - 1]
                [tuple.symbolCount[1 - lastMove.symbol!]];
      }
      if (!tuple.bothSymbols) {
        int tupleValue = tupleEval[this._winSequenceLength - 1]
            [tuple.symbolCount[lastMove.symbol!]];
        if (tupleValue >= WIN) {
          moveValue = WIN;
          break;
        }
        moveValue += tupleValue;
      }
    }

    if (moveValue >= WIN) {
      this._boardValue = (this._startSymbol == lastMove.symbol ? 1 : -1) * WIN;
      this._winSymbol = lastMove.symbol;
    } else {
      this._boardValue += (this._startSymbol == lastMove.symbol ? 1 : -1) *
          (moveValue - originalValue);
    }

    // _log.finest('MOVE: ${lastMove}, BOARD VALUE: ${this._boardValue}, WINNER: ${this._winSymbol}, BOARD = ${this._board}');
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
