import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:logging/logging.dart';

import '../providers/app_settings.dart';
import '../widgets/welcome_option_button.dart';

Logger _log = Logger('WelcomeOptions');

class WelcomeOptions extends StatelessWidget {
  const WelcomeOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vyber si úroveň obtížnosti a začni hrát.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            height: 16,
          ),
          LimitedBox(
            maxHeight: 250,
            child: ListView.builder(
              itemCount: AppSettings.getAgeCategories().length,
              itemBuilder: (BuildContext ctx, int index) {
                return WelcomeOptionButton(
                  title: AppSettings.getAgeCategories()[index]['title'],
                  subtitle: AppSettings.getAgeCategories()[index]['subtitle'],
                  routeToMain: () {
                    routeToMain(ctx, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void routeToMain(BuildContext context, int index) {
    _log.finest('Route to ${index} category');
    AppSettings.setAgeCategory(index);
    GoRouter.of(context).go('/');
  }
}

/*
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: AppSettings.getAgeCategories().length,
                itemBuilder: (BuildContext ctx, int index) {
                  return ElevatedButton(
                    onPressed: () {
                      AppSettings.setAgeCategory(index);
                      GoRouter.of(context).go('/');
                    },
                    child: Text(AppSettings.getAgeCategories()[index]),
                  );
                },
              ),
*/
