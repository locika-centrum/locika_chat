import 'package:logging/logging.dart';

import './game_move.dart';

Logger _log = Logger('GameBoard - sliding');

class GameBoard {
  final int settingsSize;
  late int _size;
  late List<List<int?>> _board;
  late int _moves = 0;

  List<List<int?>> get board => this._board;
  int get size => this._size;
  int get moves => this._moves;

  GameBoard({required int this.settingsSize}) {
    switch (this.settingsSize) {
      case 1:
        _size = 4;
        break;
      case 2:
        _size = 5;
        break;
      case 3:
        _size = 6;
        break;
      default:
        _size = 3;
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

    List<int?> values = List.generate(
      this._size * this._size,
      (index) => index == 0 ? null : index,
      growable: false,
    );
    values.shuffle();
    _log.finest('List of values: ${values}');

    for (int row = 0; row < _size; row++) {
      for (int col = 0; col < _size; col++) {
        this._board[row][col] = values[_size * row + col];
      }
    }
    _log.finest('List of values: ${_board}');
  }

  GameMove? recordCoordinates(int row, int col) {
    // find empty cell
    if (this._board[row][col] == null) return null;

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (row + i >= 0 &&
            col + j >= 0 &&
            row + i < _size &&
            col + j < _size &&
            i.abs() != j.abs()) {
          if (this._board[row + i][col + j] == null) {
            this._board[row + i][col + j] = this._board[row][col];
            this._board[row][col] = null;
            _moves++;
            return GameMove(row: row + i, col: col + j);
          }
        }
      }
    }

    return null;
  }

  bool evaluateBoard() {
    if (board[this._size - 1][this._size - 1] != null) return false;

    for (int i = 0; i < this._size * this._size - 1; i++) {
      if (board[i ~/ this._size][i % this._size] != i + 1) return false;
    }

    return true;
  }
}
