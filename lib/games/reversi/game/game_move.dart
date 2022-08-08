class GameMove {
  final int row;
  final int col;
  final int symbol;
  int value = 0;
  bool lastMove = false;

  GameMove({
    required this.row,
    required this.col,
    required this.symbol,
  });

  String toString() => '[$row, $col] with $symbol > $value}';

  bool equal(GameMove move) =>
      this.row == move.row &&
          this.col == move.col &&
          this.symbol == move.symbol;
}