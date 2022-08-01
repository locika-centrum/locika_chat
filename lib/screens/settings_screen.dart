import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_settings.dart';

Logger _log = Logger('SettingsScreen');

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool violetMode = AppSettings().data.violetModeOn;
  bool showSpecialSection = AppSettings().data.isEligibleForVioletMode;

  void _afterAgeCategorySelection() {
    setState(() {
      showSpecialSection = AppSettings().data.isEligibleForVioletMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SettingsList(sections: [
        SettingsSection(
          title: const Text('Obecné'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.face),
              title: const Text('Kategorie'),
              value: Text(AppSettings().data.ageCategories[
                  AppSettings().data.ageCategory ??
                      AppSettings().data.ageCategories.length - 1]['category']),
              onPressed: (context) => GoRouter.of(context).push(
                '/settings/category',
                extra: _afterAgeCategorySelection,
              ),
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.view_comfy),
              title: const Text('Velikost hry'),
              value: Text(
                  AppSettings().data.gameSizes[AppSettings().data.gameSize]),
              onPressed: (context) =>
                  GoRouter.of(context).push('/settings/game_size'),
            ),
            SettingsTile(
              leading: const Icon(Icons.redo),
              title: const Text('Reset score'),
              onPressed: (context) {
                AppSettings().data.resetScore();

                SnackBar snackBar = const SnackBar(
                  content: Text('Score je vymazané.'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            )
          ],
        ),
        if (showSpecialSection)
          SettingsSection(
            title: const Text('Speciální'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) => setState(() {
                  AppSettings().data.toggleVioletMode();
                }),
                initialValue: AppSettings().data.violetModeOn,
                leading: const Icon(Icons.lock),
                title: const Text('Fialový režim'),
              ),
              if (AppSettings().data.violetModeOn)
                SettingsTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fialový režim je prostor, kde si.... bla bla.. dasdadasdsa.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () {
                          GoRouter.of(context).push('/about_violet_mode');
                        },
                        child: Text(
                          'Jak to funguje',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.blue,
                                  ),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        SettingsSection(
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.info_outline),
              title: const Text('O aplikaci'),
              onPressed: (context) => GoRouter.of(context).push('/about'),
            ),
            SettingsTile(
              leading: const Icon(
                Icons.redo,
                color: Colors.red,
              ),
              title: const Text(
                'Resetovat aplikaci',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: (context) {
                AppSettings().data.resetAll();

                SnackBar snackBar = const SnackBar(
                  content: Text('Data aplikace jsou smazaná'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                GoRouter.of(context).go('/welcome');
              },
            )
          ],
        ),
      ]),
    );
  }
}
