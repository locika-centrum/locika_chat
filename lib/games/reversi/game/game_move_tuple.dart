import 'game_move.dart';

class GameMoveTuple {
  List<GameMove> moves = [];
  List<int> symbolCount = [0, 0];

  bool get bothSymbols => symbolCount[0] > 0 && symbolCount[1] > 0;
  int get length => moves.length;

  void add(GameMove move) {
    moves.add(move);
    symbolCount[move.symbol]++;
  }
}