import 'package:flutter/material.dart';

class AppColors {
  // PLANET 메인 컬러
  static const Color primary = Color(0xFF5B63F6);

  // 밝은 보라색
  static const Color primaryLight = Color(0xFFB9C5FF);

  // 진한 네이비
  static const Color navy = Color(0xFF17275B);

  // 포인트 핑크
  static const Color pink = Color(0xFFFF8CC7);

  // 배경
  static const Color background = Color(0xFFF3F5FF);

  // 카드
  static const Color card = Colors.white;

  // 텍스트
  static const Color textPrimary = Color(0xFF1E2A5A);

  static const Color textSecondary = Color(0xFF7885A8);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: AppColors.background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF9AA0B5),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
