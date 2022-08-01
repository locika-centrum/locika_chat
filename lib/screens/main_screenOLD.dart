import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../responsive_ui/two_sections_ui.dart';

class MainScreenOLD extends StatelessWidget {
  const MainScreenOLD({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Naše supr hra'),
      ),
      body: TwoSectionUI(
        firstSection: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset('assets/images/monster_01.svg'),
        ),
        secondSection: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  GoRouter.of(context)
                      .push('/game');
                },
                child: const Text('Hra'),
              ),
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).push('/settings');
                },
                child: const Text('Nastavení'),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
