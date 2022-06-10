import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../providers/app_theme.dart';
import '../providers/app_settings.dart';

Logger _log = Logger('main.dart');

Future<void> main() async {
  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((record) {
    print(
        '[${record.level.name}] ${record.time} [${record.loggerName}]: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locika chat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const Scaffold(),
    );
  }
}
