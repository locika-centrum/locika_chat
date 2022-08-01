import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../providers/app_settings.dart';

class SettingsGameSizeScreen extends StatefulWidget {
  const SettingsGameSizeScreen({Key? key}) : super(key: key);

  @override
  State<SettingsGameSizeScreen> createState() => _SettingsGameSizeScreenState();
}

class _SettingsGameSizeScreenState extends State<SettingsGameSizeScreen> {
  int gameSize = AppSettings().data.gameSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Velikost hry'),
        elevation: 0,
      ),
      body: SettingsList(sections: [
        SettingsSection(
          title: const Text('Vyber velikost hry'),
          tiles: [..._settingTiles(context)],
        )
      ]),
    );
  }

  List<SettingsTile> _settingTiles(BuildContext context) {
    List<SettingsTile> result = [];

    for (int index = 0; index < AppSettings().data.gameSizes.length; index++) {
      result.add(SettingsTile(
        title: Text(AppSettings().data.gameSizes[index]),
        trailing:
            Icon(index == AppSettings().data.gameSize ? Icons.visibility : null),
        onPressed: (context) {
          setState(() {
            AppSettings().data.setGameSize(index);
            gameSize = index;
          });
        },
      ));
    }
    return result;
  }
}
