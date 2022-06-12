import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_settings.dart';

class SecretButton extends StatelessWidget {
  // set to 0.0 in final version to hide the secret button
  static const _opacity = 0.1;

  const SecretButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacity,
      child: FloatingActionButton(onPressed: () {
        if (AppSettings.isEligibleForVioletMode() && AppSettings.violetModeOn.value) {
          _showOptions(context);
        }
      }),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Dáš si pauzu?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Zpět'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        GoRouter.of(context).push('/chat_room');
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOptionsOLD(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Äas na pauzu?"),
            actions: [
              TextButton(onPressed: () {}, child: const Text('ZpÄt')),
              TextButton(onPressed: () {}, child: const Text('OK')),
            ],
          );
        });
  }
}
