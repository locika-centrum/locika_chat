class GameMove {
  final int row;
  final int col;

  GameMove({
    required this.row,
    required this.col,
  });

  String toString() => '($row, $col)';
}