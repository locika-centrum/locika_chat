import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../providers/app_theme.dart';
import '../providers/app_settings.dart';
import './screens/main_screen.dart';
import './screens/welcome_screen.dart';
import './screens/settings/settings_category.dart';
import './screens/settings/settings_game_size.dart';
import './screens/chat_room_screen.dart';
import './screens/chat_screen.dart';
import './screens/login_screen.dart';
import './screens/register_screen.dart';
import './screens/network_error_screen.dart';
import './screens/about_screen.dart';
import './screens/about_violet_mode_screen.dart';

Logger _log = Logger('main.dart');

Future<void> main() async {
  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((record) {
    print(
        '[${record.level.name}] ${record.time} [${record.loggerName}]: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final _router = GoRouter(
    initialLocation: AppSettings().data.ageCategory == null ? '/welcome' : '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MainScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/about_violet_mode',
        builder: (context, state) => const AboutVioletModeScreen(),
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
        path: '/login',
        builder: (context, state) {
          return LoginScreen(
            nextRoute: '/chat_room',
            nickName: AppSettings().data.nickName,
            setCookie: (Cookie cookie) => AppSettings().data.setCookie(cookie),
            setNick: (String nickName) => AppSettings().data.setNickName(nickName),
          );
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          return RegisterScreen(
            nextRoute: '/chat_room',
            setCookie: (Cookie cookie) => AppSettings().data.setCookie(cookie),
            setNick: (String nickName) => AppSettings().data.setNickName(nickName),
          );
        },
      ),
      GoRoute(
        path: '/chat_room',
        builder: (context, state) => ChatRoomScreen(
          cookie: AppSettings().data.cookie!,
        ),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          String? chatID = state.params['id'];

          // TODO check if chatID is null
          return ChatScreen(
            nickName: AppSettings().data.nickName!,
            cookie: AppSettings().data.cookie!,
            setCookie: (Cookie cookie) => AppSettings().data.setCookie(cookie),
            advisorID: chatID!,
          );
        },
      ),
      GoRoute(
        path: '/network_error',
        builder: (context, state) => const NetworkErrorScreen(),
      )
    ],
  );

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _log.finest('Starting with parameters: ${AppSettings().data}');
    return MaterialApp.router(
      title: 'Locika chat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}
