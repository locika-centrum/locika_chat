import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locika_chat/providers/app_settings.dart';

import '../responsive_ui/two_sections_ui.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Naše supr hra'),
      ),
      body: TwoSectionUI(
        firstSection: const Text('logo'),
        secondSection: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  GoRouter.of(context)
                      .push('/game?size=${AppSettings.gameSize.value}');
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
