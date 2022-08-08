import 'dart:math';

import 'package:logging/logging.dart';

import './game_move.dart';
import './game_move_tuple.dart';

Logger _log = Logger('GameBoard - reversi');

class GameBoard {
  final int settingsSize;
  late int _size;
  late List<List<int?>> _board;
  late List<List<bool?>> _surrounding;
  late int _startSymbol = 0; // Always black starts
  late int _symbol;
  late int _availableMoves;
  int? _winSymbol;
  int _boardValue = 0;
  List<int> _symbolCount = [0, 0];

  List<List<int?>> get board => this._board;
  List<List<bool?>> get surrounding => this._surrounding;
  int get size => this._size;
  int get activeSymbol => this._symbol;
  int get availableMoves => this._availableMoves;
  int? get winSymbol => this._winSymbol;
  int get boardValue => this._boardValue;
  List<int> get symbolCount => this._symbolCount;

  GameBoard({required int this.settingsSize}) {
    this._symbol = this._startSymbol;

    switch (this.settingsSize) {
      case 1:
        this._size = 6;
        break;
      case 2:
        this._size = 8;
        break;
      case 3:
        this._size = 10;
        break;
      default:
        this._size = 4;
    }
    this._board = List.generate(
      this._size,
      (index) => List.generate(
        this._size,
        (index) => null,
        growable: false,
      ),
      growable: false,
    );

    // Initial position
    this._board[this._size ~/ 2 - 1][this._size ~/ 2] =
        this._board[this._size ~/ 2][this._size ~/ 2 - 1] = 0;
    this._board[this._size ~/ 2 - 1][this._size ~/ 2 - 1] =
        this._board[this._size ~/ 2][this._size ~/ 2] = 1;

    this._symbolCount[0] = this._symbolCount[1] = 2;
    this._availableMoves = this._size * this._size - 4;

    // Surroundings
    this._surrounding = List.generate(
      this._size,
      (row) => List.generate(
        this._size,
        (col) => this._board[row][col] != null
            ? null
            : row >= this._size ~/ 2 - 2 &&
                row <= this._size ~/ 2 + 1 &&
                col >= this._size ~/ 2 - 2 &&
                col <= this._size ~/ 2 + 1,
        growable: false,
      ),
      growable: false,
    );
  }

  void pass() {
    this._symbol = 1 - this._symbol;
  }

  GameMove? recordCoordinates(int row, int col, bool aiPlayer) {
    GameMove? result;

    if (this._board[row][col] == null) {
      result = GameMove(row: row, col: col, symbol: this._symbol);

      // Execute the move
      List<GameMoveTuple> moveTuples = tuplesChangingColor(result);
      if (moveTuples.length == 0) {
        // Invalid move
        result = null;
      } else {
        this._board[row][col] = this._symbol;
        this._symbolCount[this._symbol]++;
        for (GameMoveTuple tuple in moveTuples) {
          _log.finest('Changing: ${tuple.moves}');
          for (GameMove move in tuple.moves) {
            this._board[move.row][move.col] = this._symbol;
            this._symbolCount[this._symbol]++;
            this._symbolCount[1 - this._symbol]--;
          }
        }

        // Modify surroundings
        for (int i = -1; i < 2; i++) {
          for (int j = -1; j < 2; j++) {
            if (row + i >= 0 &&
                row + i < this._size &&
                col + j >= 0 &&
                col + j < this._size)
              this._surrounding[row + i][col + j] = (i == 0 && j == 0)
                  ? null
                  : this._surrounding[row + i][col + j] == null
                      ? null
                      : true;
          }
        }

        // TODO evaluate board

        this._symbol = 1 - this._symbol;
        this._availableMoves--;
      }
    }

    return result;
  }

  GameMove? recordMove(GameMove? move, bool aiPlayer) {
    return move == null
        ? null
        : recordCoordinates(move.row, move.col, aiPlayer);
  }

  List<GameMoveTuple> tuplesChangingColor(GameMove move) {
    List<GameMoveTuple> result = [];

    // horizontal
    GameMoveTuple tuple = GameMoveTuple();
    for (int i = move.col + 1; i < this._size; i++) {
      if (this._board[move.row][i] == move.symbol) break;
      if (i == this._size - 1 || this._board[move.row][i] == null) {
        tuple = GameMoveTuple();
        break;
      }
      tuple.add(GameMove(row: move.row, col: i, symbol: 1 - move.symbol));
    }
    if (tuple.length > 0) result.add(tuple);

    tuple = GameMoveTuple();
    for (int i = move.col - 1; i >= 0; i--) {
      if (this._board[move.row][i] == move.symbol) break;
      if (i == 0 || this.board[move.row][i] == null) {
        tuple = GameMoveTuple();
        break;
      }
      tuple.add(GameMove(row: move.row, col: i, symbol: 1 - move.symbol));
    }
    if (tuple.length > 0) result.add(tuple);

    // vertical
    tuple = GameMoveTuple();
    for (int i = move.row + 1; i < this._size; i++) {
      if (this._board[i][move.col] == move.symbol) break;
      if (i == this._size - 1 || this._board[i][move.col] == null) {
        tuple = GameMoveTuple();
        break;
      }
      tuple.add(GameMove(row: i, col: move.col, symbol: 1 - move.symbol));
    }
    if (tuple.length > 0) result.add(tuple);

    tuple = GameMoveTuple();
    for (int i = move.row - 1; i >= 0; i--) {
      if (this._board[i][move.col] == move.symbol) break;
      if (i == 0 || this.board[i][move.col] == null) {
        tuple = GameMoveTuple();
        break;
      }
      tuple.add(GameMove(row: i, col: move.col, symbol: 1 - move.symbol));
    }
    if (tuple.length > 0) result.add(tuple);

    // diagonal left_up-right_down
    tuple = GameMoveTuple();
    for (int i = 1; i <= this._size - max(move.row + 1, move.col + 1); i++) {
      if (this._board[move.row + i][move.col + i] == move.symbol) break;
      if (i == this._size - max(move.row + 1, move.col + 1) ||
          this._board[move.row + i][move.col + i] == null) {
        tuple = GameMoveTuple();
        break;
      }
      tuple.add(GameMove(
          row: move.row + i, col: move.col + i, symbol: 1 - move.symbol));
    }
    if (tuple.length > 0) result.add(tuple);

    tuple = GameMoveTuple();
    for (int i = 1; i <= min(move.row, move.col); i++) {
      if (this._board[move.row - i][move.col - i] == move.symbol) break;
      if (i == min(move.row, move.col) ||
          this._board[move.row - i][move.col - i] == null) {
        tuple = GameMoveTuple();
        break;
      }
      tuple.add(GameMove(
          row: move.row - i, col: move.col - i, symbol: 1 - move.symbol));
    }
    if (tuple.length > 0) result.add(tuple);

    // diagonal right_up-left_down
    tuple = GameMoveTuple();
    for (int i = 1; i <= min(move.row, this._size - move.col - 1); i++) {
      if (this._board[move.row - i][move.col + i] == move.symbol) break;
      if (i == min(move.row, this._size - move.col - 1) ||
          this._board[move.row - i][move.col + i] == null) {
        tuple = GameMoveTuple();
        break;
      }
      tuple.add(GameMove(
          row: move.row - i, col: move.col + i, symbol: 1 - move.symbol));
    }
    if (tuple.length > 0) result.add(tuple);

    tuple = GameMoveTuple();
    for (int i = 1; i <= min(this._size - move.row - 1, move.col); i++) {
      if (this._board[move.row + i][move.col - i] == move.symbol) break;
      if (i == min(this._size - move.row - 1, move.col) ||
          this._board[move.row + i][move.col - i] == null) {
        tuple = GameMoveTuple();
        break;
      }
      tuple.add(GameMove(
          row: move.row + i, col: move.col - i, symbol: 1 - move.symbol));
    }
    if (tuple.length > 0) result.add(tuple);

    return result;
  }

  GameBoard clone() {
    GameBoard result =
    GameBoard(settingsSize: this.settingsSize);

    // Copy board
    for (int row = 0; row < result._size; row++) {
      for (int col = 0; col < result._size; col++) {
        result._board[row][col] = this._board[row][col];
        result._surrounding[row][col] = this._surrounding[row][col];
      }
    }

    // Set additional values
    result._symbol = this._symbol;
    result._availableMoves = this._availableMoves;
    result._boardValue = this._boardValue;
    result._symbolCount = [this._symbolCount[0], this._symbolCount[1]];

    return result;
  }
}
