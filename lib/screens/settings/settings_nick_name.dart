import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_settings.dart';

class SettingsNickNameScreen extends StatefulWidget {
  const SettingsNickNameScreen({Key? key}) : super(key: key);

  @override
  State<SettingsNickNameScreen> createState() => _SettingsNickNameScreenState();
}

class _SettingsNickNameScreenState extends State<SettingsNickNameScreen> {
  final _nickNameController =
      TextEditingController(text: AppSettings.nickName.value);

  void _updateNickName() {
    String? nickName;

    nickName = _nickNameController.text.trim();
    if (nickName.isEmpty) {
      nickName = null;
    }
    AppSettings.setNickName(nickName);
    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: _updateNickName,
        ),
        title: const Text('Nastav si přezdívku'),
        elevation: 0,
      ),
      body: SettingsList(sections: [
        SettingsSection(
          tiles: [
            SettingsTile(
              title: SizedBox(
                height: 24,
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  controller: _nickNameController,
                  onSubmitted: (_) => _updateNickName(),
                  maxLength: 15,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.grey,),
                onPressed: () {
                  _nickNameController.clear();
                },
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
