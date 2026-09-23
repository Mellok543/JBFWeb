import 'package:flutter/material.dart';

class JbfColors {
  static const bg0 = Color(0xFF05090D);
  static const bg1 = Color(0xFF071017);
  static const bg2 = Color(0xFF0B151C);

  static const panel0 = Color(0xFF0D181F);
  static const panel1 = Color(0xFF101D24);

  static const accentLime = Color(0xFFCAFF39);
  static const accentCyan = Color(0xFF5CE8FF);

  static const textPrimary = Color(0xFFF2F6F7);
  static const textSecondary = Color(0xFF7D9098);

  static const error = Color(0xFFFF6072);
  static const warning = Color(0xFFFFD05C);
  static const success = Color(0xFF6BE29F);

  static const borderCyan = Color(0x405CE8FF);
  static const borderLime = Color(0x99CAFF39);
}

class JbfRadii {
  static const sm = 2.0;
  static const md = 4.0;
}

final ThemeData jbfTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: JbfColors.bg0,
  colorScheme: const ColorScheme.dark(
    surface: JbfColors.bg0,
    primary: JbfColors.accentLime,
    secondary: JbfColors.accentCyan,
    error: JbfColors.error,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: JbfColors.textPrimary),
    bodySmall: TextStyle(color: JbfColors.textSecondary),
  ),
);
