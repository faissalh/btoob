import 'package:flutter/material.dart';

class AppColors {
  static const Color bg = Color(0xFFF4F8FF);
  static const Color bg2 = Color(0xFFEAF1FC);
  static const Color panel = Color(0xFFFFFFFF);
  static const Color panel2 = Color(0xFFF5F8FE);
  static const Color fg = Color(0xFF172B4D);
  static const Color muted = Color(0xFF526783);
  static const Color muted2 = Color(0xFF71839D);
  static const Color accent = Color(0xFF2563EB);
  static const Color accent2 = Color(0xFF1D4ED8);
  static const Color accentSoft = Color(0x1A2563EB);
  static const Color green = Color(0xFF22C55E);
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color line = Color(0xFFD9E4F4);
  static const Color line2 = Color(0xFFB8CBEA);

  static const Color darkBg = Color(0xFF0F1724);
  static const Color darkBg2 = Color(0xFF1A2438);
  static const Color darkPanel = Color(0xFF1E293B);
  static const Color darkPanel2 = Color(0xFF253347);
  static const Color darkFg = Color(0xFFE2E8F0);
  static const Color darkMuted = Color(0xFF94A3B8);
  static const Color darkMuted2 = Color(0xFF64748B);
  static const Color darkLine = Color(0xFF334155);
  static const Color darkLine2 = Color(0xFF475569);
}

class AppTheme {
  static const double radiusSm = 10;
  static const double radius = 14;
  static const double radiusLg = 20;

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF2563EB).withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get softShadowDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.accent,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.accent2,
        surface: AppColors.panel,
        error: AppColors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.fg,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.panel,
        foregroundColor: AppColors.fg,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panel2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.muted2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.panel2,
        selectedColor: AppColors.accentSoft,
        labelStyle: const TextStyle(color: AppColors.fg, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        side: const BorderSide(color: AppColors.line),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.panel,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.muted2,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.fg,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.accent,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accent2,
        surface: AppColors.darkPanel,
        error: AppColors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkFg,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkPanel,
        foregroundColor: AppColors.darkFg,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkPanel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.darkLine, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkPanel2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.darkLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.darkLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.darkMuted2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkPanel2,
        selectedColor: AppColors.accentSoft,
        labelStyle: const TextStyle(color: AppColors.darkFg, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        side: const BorderSide(color: AppColors.darkLine),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkPanel,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.darkMuted2,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkLine,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkFg,
        contentTextStyle: const TextStyle(color: AppColors.darkBg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
