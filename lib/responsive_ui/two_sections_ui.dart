import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Logger _log = Logger('TwoSectionUI');

class TwoSectionUI extends StatelessWidget {
  final Widget firstSection;
  final Widget secondSection;

  const TwoSectionUI(
      {required this.firstSection, required this.secondSection, Key? key})
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
                child: Center(child: firstSection),
              ),
            ),
            Expanded(
              child: SafeArea(
                child: Center(child: secondSection),
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
                child: Center(child: firstSection),
              ),
            ),
            Expanded(
              child: SafeArea(
                child: Center(child: secondSection),
              ),
            ),
          ],
        );
      }
    });
  }
}
