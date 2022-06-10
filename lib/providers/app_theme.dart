import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: ThemeData.light().textTheme.copyWith(
      bodyLarge: const TextStyle(
        fontSize: 48,
      ),
      bodyMedium: const TextStyle(
        fontSize: 20,
      ),
      labelLarge: const TextStyle(
        fontSize: 18,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: ThemeData.dark().textTheme.copyWith(
      bodyLarge: const TextStyle(
        fontSize: 48,
      ),
      bodyMedium: const TextStyle(
        fontSize: 20,
      ),
      labelLarge: const TextStyle(
        fontSize: 18,
      ),
    ),
  );

  static final violetTheme = ThemeData();
}
