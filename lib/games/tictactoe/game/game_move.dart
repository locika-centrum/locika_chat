class GameMove {
  final int row;
  final int col;
  int? symbol;
  int value = 0;
  int? winningMove = null;

  GameMove({
    required this.row,
    required this.col,
    this.symbol,
  });

  String toString() => '[$row, $col] with $symbol > $value}';

  bool equal(GameMove move) =>
      this.row == move.row &&
      this.col == move.col &&
      this.symbol == move.symbol;
}
