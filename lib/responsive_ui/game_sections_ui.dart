import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Logger _log = Logger('GameSectionUI');

class GameSectionUI extends StatelessWidget {
  final Widget scoreSection;
  final Widget gameSection;
  final Widget notificationSection;
  final Widget actionSection;

  const GameSectionUI(
      {required this.scoreSection,
      required this.gameSection,
      required this.notificationSection,
      required this.actionSection,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;

      if (size.height >= size.width) {
        _log.finest('portrait -> content to columns');
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: SafeArea(
                child: Center(child: scoreSection),
              ),
            ),
            Expanded(
              child: SafeArea(
                child: Center(child: gameSection),
              ),
            ),
            Expanded(
              child: SafeArea(
                child: Center(child: notificationSection),
              ),
            ),
            Expanded(
              child: SafeArea(
                child: Center(child: actionSection),
              ),
            ),
          ],
        );
      } else {
        _log.finest('landscape -> content to rows');
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: SafeArea(
                child: Center(child: scoreSection),
              ),
            ),
            Expanded(
              child: SafeArea(
                child: Center(child: gameSection),
              ),
            ),
          ],
        );
      }
    });
  }
}
