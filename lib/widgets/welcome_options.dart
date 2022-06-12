import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_settings.dart';

class WelcomeOptions extends StatelessWidget {
  final bool showTitle;

  const WelcomeOptions({Key? key, this.showTitle = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            Text(
              'Vítej',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          if (showTitle)
            const Text(
                'Vyber si vlastní kategorii, ať hru přizpůsobíme tvému věku'),
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
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
            ),
          )
        ],
      ),
    );
  }
}
