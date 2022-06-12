import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../providers/app_theme.dart';
import '../providers/app_settings.dart';
import './screens/main_screen.dart';
import './screens/welcome_screen.dart';
import './screens/game_screen.dart';
import './screens/settings_screen.dart';
import './screens/settings/settings_category.dart';
import './screens/settings/settings_game_size.dart';
import './screens/settings/settings_nick_name.dart';
import './screens/chat_room_screen.dart';
import './screens/chat_screen.dart';

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
  static final _router = GoRouter(
    initialLocation: AppSettings.ageCategory.value == null ? '/welcome' : '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) {
          final gameSize = int.parse(state.queryParams['size']!);
          _log.finest(gameSize);
          return GameScreen(gameSize: gameSize);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/category',
        builder: (context, state) => SettingsCategoryScreen(
          onChange: state.extra as Function,
        ),
      ),
      GoRoute(
        path: '/settings/game_size',
        builder: (context, state) => const SettingsGameSizeScreen(),
      ),
      GoRoute(
        path: '/settings/nick_name',
        builder: (context, state) => const SettingsNickNameScreen(),
      ),
      GoRoute(
        path: '/chat_room',
        builder: (context, state) => ChatRoomScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          String? chatID = state.params['id'];

          return ChatScreen(chatID: chatID,);
        },
      ),
    ],
  );

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _log.finest('Starting with parameters:\n'
        '  > Nick name: ${AppSettings.nickName.value}\n'
        '  > Age category: ${AppSettings.ageCategory.value}\n'
        '  > Game size: ${AppSettings.gameSize.value}\n'
        '  > Violet mode: ${AppSettings.violetModeOn.value}');
    return MaterialApp.router(
      title: 'Locika chat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}
