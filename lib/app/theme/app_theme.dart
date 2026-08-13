import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Blue-green palette
  static const Color primaryBlue = Color(0xFF7AAACE);
  static const Color primaryDark = Color(0xFF355872);
  static const Color accentGreen = Color(0xFF20B2AA);
  static const Color accentGreenDark = Color(0xFF005D4B);
  static const Color lightCyan = Color(0xFF9CD5FF);
  static const Color lightGreen = lightCyan;
  static const Color bgLight = Color(0xFFF7F8F0);
  static const Color textDark = Color(0xFF355872);
  static const Color textLight = Color(0xFF7B8799);
  static const Color surfaceTint = Color(0xFFE8F5F3);
  static const Color surfaceTintBlue = Color(0xFFE8F4FA);

  // Legacy aliases — map to blue-green
  static const Color sageGreen = accentGreen;
  static const Color cyan = primaryBlue;
  static const Color accentTeal = accentGreen;
  static const Color verdeTosca = accentGreen;
  static const Color purple = accentGreen;
  static const Color purpleLight = lightCyan;
  static const Color lightGreenPale = surfaceTint;
  static const Color successGreen = Color(0xFF28A745);
  static const Color warningOrange = Color(0xFFFFA500);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(),
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: accentGreen,
      tertiary: accentGreenDark,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: bgLight,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 1,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: accentGreen,
      unselectedItemColor: textLight,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentGreen,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: primaryBlue, width: 1),
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
        borderSide: const BorderSide(color: accentGreen, width: 2),
      ),
      labelStyle: const TextStyle(color: textDark),
      prefixIconColor: primaryBlue,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        side: const BorderSide(color: accentGreen, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [primaryBlue, accentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [accentGreen, lightCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient statusCardGradient = LinearGradient(
    colors: [primaryBlue, accentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static const BorderRadius br8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius br12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius br16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius br20 = BorderRadius.all(Radius.circular(20));
}
