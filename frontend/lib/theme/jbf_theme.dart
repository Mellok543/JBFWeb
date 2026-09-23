import 'package:flutter/material.dart';

class JbfColors {
  static const bg0 = Color(0xFF05080D);
  static const bg1 = Color(0xFF081018);
  static const bg2 = Color(0xFF0C151D);
  static const panel0 = Color(0xFF0D171F);
  static const panel1 = Color(0xFF111E27);
  static const panel2 = Color(0xFF162630);
  static const accentLime = Color(0xFFC9FF43);
  static const accentCyan = Color(0xFF55E7FF);
  static const accentBlue = Color(0xFF5A87FF);
  static const accentPurple = Color(0xFF9A7CFF);
  static const textPrimary = Color(0xFFF4F8FA);
  static const textSecondary = Color(0xFF8FA2AB);
  static const textMuted = Color(0xFF61727A);
  static const error = Color(0xFFFF6678);
  static const warning = Color(0xFFFFD05C);
  static const success = Color(0xFF6BE29F);
  static const border = Color(0x1FFFFFFF);
  static const borderCyan = Color(0x405CE8FF);
  static const borderLime = Color(0x66CAFF39);
}

class JbfRadii {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 22.0;
}

final ThemeData jbfTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: JbfColors.bg0,
  colorScheme: const ColorScheme.dark(
    surface: JbfColors.panel0,
    primary: JbfColors.accentLime,
    secondary: JbfColors.accentCyan,
    tertiary: JbfColors.accentPurple,
    error: JbfColors.error,
  ),
  dividerColor: JbfColors.border,
  cardTheme: CardThemeData(
    color: JbfColors.panel0,
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(JbfRadii.md),
      side: const BorderSide(color: JbfColors.border),
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: JbfColors.textPrimary, fontWeight: FontWeight.w900, letterSpacing: -1.2),
    headlineMedium: TextStyle(color: JbfColors.textPrimary, fontWeight: FontWeight.w800),
    titleLarge: TextStyle(color: JbfColors.textPrimary, fontWeight: FontWeight.w800),
    bodyLarge: TextStyle(color: JbfColors.textPrimary, height: 1.55),
    bodyMedium: TextStyle(color: JbfColors.textPrimary, height: 1.5),
    bodySmall: TextStyle(color: JbfColors.textSecondary),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: JbfColors.accentLime,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .3),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: JbfColors.textPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      side: const BorderSide(color: JbfColors.borderCyan),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
);
