import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryBlue = Color(0xFF1E88E5); // Biru utama
  static const Color primaryDark = Color(0xFF1565C0); // Biru gelap
  static const Color sageGreen = Color(0xFF7CB342); // Sage green
  static const Color lightGreen = Color(0xFF9CCC65); // Light green
  static const Color cyan = Color(0xFF00BCD4); // Cyan
  static const Color accentTeal = Color(0xFF00838F); // Teal accent
  static const Color lightCyan = Color(0xFFB2EBF2); // Light cyan
  static const Color bgLight = Color(0xFFF5F7FA); // Background light
  static const Color textDark = Color(0xFF1F2937); // Text dark
  static const Color textLight = Color(0xFF6B7280); // Text light

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: sageGreen,
      tertiary: cyan,
      surface: Colors.white,
      background: bgLight,
    ),
    scaffoldBackgroundColor: bgLight,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textLight,
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: textDark),
      prefixIconColor: primaryBlue,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        side: const BorderSide(color: primaryBlue),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textLight,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        color: textLight,
      ),
    ),
  );

  // Gradients
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primaryBlue, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient greenGradient = const LinearGradient(
    colors: [sageGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cyanGradient = const LinearGradient(
    colors: [cyan, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient mixedGradient = const LinearGradient(
    colors: [primaryBlue, cyan, sageGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // Border radius
  static const BorderRadius br8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius br12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius br16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius br20 = BorderRadius.all(Radius.circular(20));
}
