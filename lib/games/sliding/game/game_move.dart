class GameMove {
  final int row;
  final int col;
  bool winningMove = false;

  GameMove({
    required this.row,
    required this.col,
  });

  String toString() => '($row, $col)';
}