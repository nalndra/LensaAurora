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

  // Soft neutral fill used behind inputs/chips instead of a hard border.
  static const Color fieldFill = Color(0xFFF1F5F8);

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
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: bgLight,
      foregroundColor: textDark,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: accentGreen,
      unselectedItemColor: textLight,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentGreen,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: StadiumBorder(),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: br20),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fieldFill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: br16,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: br16,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: br16,
        borderSide: const BorderSide(color: accentGreen, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: br16,
        borderSide: const BorderSide(color: Color(0xFFE4574C), width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: br16,
        borderSide: const BorderSide(color: Color(0xFFE4574C), width: 1.8),
      ),
      hintStyle: TextStyle(color: textLight.withValues(alpha: 0.8)),
      labelStyle: const TextStyle(color: textLight),
      floatingLabelStyle: const TextStyle(color: accentGreen),
      prefixIconColor: textLight,
      suffixIconColor: textLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGreen,
        foregroundColor: Colors.white,
        disabledBackgroundColor: accentGreen.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: br16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        side: const BorderSide(color: fieldFill, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: br16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentGreenDark,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: textLight.withValues(alpha: 0.18),
      thickness: 1,
      space: 32,
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
    color: primaryDark.withValues(alpha: 0.06),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.10),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];

  /// Soft, brand-tinted shadow for elevated cards/sheets (replaces hard
  /// borders — floats content instead of outlining it).
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: primaryDark.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  /// Colored glow shadow for primary gradient CTAs.
  static List<BoxShadow> shadowButton(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static const BorderRadius br8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius br12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius br16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius br20 = BorderRadius.all(Radius.circular(20));
  static const BorderRadius br24 = BorderRadius.all(Radius.circular(24));
  static const BorderRadius br32 = BorderRadius.all(Radius.circular(32));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(999));

  // 8pt spacing scale.
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
}
