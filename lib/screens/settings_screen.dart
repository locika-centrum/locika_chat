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
  bool violetMode = AppSettings.violetModeOn.value;
  bool showSpecialSection = AppSettings.isEligibleForVioletMode();

  void _afterAgeCategorySelection() {
    setState(() {
      showSpecialSection = AppSettings.isEligibleForVioletMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Nastavení'),
        elevation: 0,
      ),
      body: SettingsList(sections: [
        SettingsSection(
          title: const Text('Obecné'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.face),
              title: const Text('Kategorie'),
              value: ValueListenableBuilder<int?>(
                builder: (BuildContext context, int? value, Widget? child) {
                  _log.finest('Category = ${AppSettings.ageCategory.value}');
                  return Text(AppSettings.getAgeCategories()[AppSettings
                          .ageCategory.value ??
                      AppSettings.getAgeCategories().length - 1]['category']);
                },
                valueListenable: AppSettings.ageCategory,
              ),
              onPressed: (context) => GoRouter.of(context).push(
                '/settings/category',
                extra: _afterAgeCategorySelection,
              ),
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.view_comfy),
              title: const Text('Velikost hry'),
              value: ValueListenableBuilder<int>(
                builder: (BuildContext context, int value, Widget? child) {
                  return Text(
                      AppSettings.getGameSizes()[AppSettings.gameSize.value]);
                },
                valueListenable: AppSettings.gameSize,
              ),
              onPressed: (context) =>
                  GoRouter.of(context).push('/settings/game_size'),
            ),
            SettingsTile(
              leading: const Icon(Icons.redo),
              title: const Text('Reset score'),
              onPressed: (context) {
                _log.finest('Reset score');
                // TODO reset score

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
                  AppSettings.toggleVioletMode();
                }),
                initialValue: AppSettings.violetModeOn.value,
                leading: const Icon(Icons.lock),
                title: const Text('Fialový mód'),
              ),
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
                AppSettings.resetAll();
                _log.finest('${AppSettings.allSettings}');

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
