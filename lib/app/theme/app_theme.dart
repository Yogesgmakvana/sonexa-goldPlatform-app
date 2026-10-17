import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB88A35)),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: AppColors.ink),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF171923),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFD6A84F),
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: Color(0xFFF4F2FA),
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        color: Color(0xFFF4F2FA),
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: Color(0xFFF4F2FA),
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(color: Color(0xFFF4F2FA)),
    ),
  );
}
