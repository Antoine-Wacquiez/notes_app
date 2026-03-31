import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.fondClair,
      primaryColor: AppColors.jauneNotes,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fondClair,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.jauneNotes,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.fondSombre,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fondSombre,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.jauneNotes,
      ),
    );
  }
}
