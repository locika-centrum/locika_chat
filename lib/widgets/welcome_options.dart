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
          Spacer(),
          LimitedBox(
            maxHeight: 250,
            child: ListView.builder(
              itemCount: AppSettings().data.ageCategories.length,
              itemBuilder: (BuildContext ctx, int index) {
                return WelcomeOptionButton(
                  title: AppSettings().data.ageCategories[index]['title'],
                  subtitle: AppSettings().data.ageCategories[index]['subtitle'],
                  routeToMain: () {
                    routeToMain(ctx, index);
                  },
                );
              },
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  void routeToMain(BuildContext context, int index) {
    _log.finest('Route to ${index} category');
    AppSettings().data.setAgeCategory(index);
    GoRouter.of(context).go('/');
  }
}
