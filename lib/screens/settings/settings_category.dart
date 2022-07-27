import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../providers/app_settings.dart';

class SettingsCategoryScreen extends StatefulWidget {
  final Function? onChange;
  const SettingsCategoryScreen({Key? key, this.onChange}) : super(key: key);

  @override
  State<SettingsCategoryScreen> createState() => _SettingsCategoryScreenState();
}

class _SettingsCategoryScreenState extends State<SettingsCategoryScreen> {
  int ageCategory = AppSettings.ageCategory.value ??
      AppSettings.getAgeCategories().length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Věková kategorie'),
        elevation: 0,
      ),
      body: SettingsList(sections: [
        SettingsSection(
          title: const Text('Vyber věkovou kategorii'),
          tiles: [..._settingTiles(context)],
        )
      ]),
    );
  }

  List<SettingsTile> _settingTiles(BuildContext context) {
    List<SettingsTile> result = [];

    for (int index = 0;
        index < AppSettings.getAgeCategories().length;
        index++) {
      result.add(SettingsTile(
        title: Text(AppSettings.getAgeCategories()[index]['category']),
        trailing: Icon(
            index == AppSettings.ageCategory.value ? Icons.visibility : null),
        onPressed: (context) {
          setState(() {
            AppSettings.setAgeCategory(index);
            ageCategory = index;
            widget.onChange!();
          });
        },
      ));
    }
    return result;
  }
}
