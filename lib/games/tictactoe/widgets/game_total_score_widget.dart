import 'package:flutter/material.dart';

import '../../../providers/app_settings.dart';

class GameTotalScoreWidget extends StatelessWidget {
  const GameTotalScoreWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Piškvorky celkem',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(
              height: 16,
            ),
            Table(
              children: _tableContent(),
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _tableContent() {
    List<TableRow> result = [];
    int totalWins, totalLoses, totalGames;
    totalWins = totalLoses = totalGames = 0;

    result.add(TableRow(children: [
      Text('V E L I K O S T', style: TextStyle(fontWeight: FontWeight.bold)),
      Center(child: Text('S C O R E', style: TextStyle(fontWeight: FontWeight.bold))),
      Center(child: Text('P O Č E T   H E R', style: TextStyle(fontWeight: FontWeight.bold))),
    ]));
    for (int i = 0; i < AppSettings().data.gameSizes.length; i++) {
      result.add(TableRow(children: [
        Text(AppSettings().data.gameSizes[i]),
        Center(
          child: Text(
              '${AppSettings().data.getTicTacToeScore(i).noOfWins} : ${AppSettings().data.getTicTacToeScore(i).noOfLosses}'),
        ),
        Center(child: Text('${AppSettings().data.getTicTacToeScore(i).noOfGames}')),
      ]));
      totalWins += AppSettings().data.getTicTacToeScore(i).noOfWins;
      totalLoses += AppSettings().data.getTicTacToeScore(i).noOfLosses;
      totalGames += AppSettings().data.getTicTacToeScore(i).noOfGames;
    }
    result.add(TableRow(children: [Text(''), Text(''), Text('')]));
    result.add(TableRow(children: [
      Text('C E L K E M', style: TextStyle(fontWeight: FontWeight.bold)),
      Center(child: Text('${totalWins} : ${totalLoses}')),
      Center(child: Text('${totalGames}')),
    ]));

    return result;
  }
}
