import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';

enum AccessibilityFont {
  plusJakarta('Plus Jakarta Sans'),
  lexend('Lexend'),
  openSans('Open Sans'),
  atkinson('Atkinson Hyperlegible');

  const AccessibilityFont(this.label);
  final String label;
}

class AccessibilityController extends GetxController {
  final isPanelOpen = false.obs;

  /// Outline: thicker borders + outlined buttons.
  final useOutline = false.obs;

  /// Accent: swap teal <-> blue.
  final useAltAccent = false.obs;

  final reduceOpacity = false.obs;
  final opacityLevel = 0.75.obs;
  final highContrast = false.obs;
  final selectedFont = AccessibilityFont.plusJakarta.obs;
  final fontScale = 1.0.obs;

  /// Offset from bottom-right corner of the screen.
  final offsetX = 16.0.obs;
  final offsetY = 100.0.obs;

  Color get accentColor =>
      useAltAccent.value ? AppTheme.primaryBlue : AppTheme.accentGreen;

  Color get accentDark =>
      useAltAccent.value ? AppTheme.primaryDark : AppTheme.accentGreenDark;

  LinearGradient get accentGradient => LinearGradient(
        colors: useAltAccent.value
            ? const [AppTheme.lightCyan, AppTheme.primaryBlue]
            : const [AppTheme.primaryBlue, AppTheme.accentGreen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  void togglePanel() => isPanelOpen.value = !isPanelOpen.value;

  void closePanel() => isPanelOpen.value = false;

  void setOutline(bool value) => useOutline.value = value;

  void setAltAccent(bool value) => useAltAccent.value = value;

  void setOpacityEnabled(bool value) => reduceOpacity.value = value;

  void setOpacityLevel(double value) =>
      opacityLevel.value = value.clamp(0.5, 1.0);

  void setHighContrast(bool value) => highContrast.value = value;

  void setFont(AccessibilityFont font) => selectedFont.value = font;

  void setFontScale(double value) => fontScale.value = value.clamp(0.85, 1.5);

  void updatePosition(double dx, double dy, Size screenSize) {
    const fabSize = 56.0;
    const margin = 8.0;
    offsetX.value =
        (offsetX.value - dx).clamp(margin, screenSize.width - fabSize - margin);
    offsetY.value = (offsetY.value - dy)
        .clamp(margin, screenSize.height - fabSize - margin);
  }

  TextTheme _buildTextTheme(TextTheme base) {
    switch (selectedFont.value) {
      case AccessibilityFont.lexend:
        return GoogleFonts.lexendTextTheme(base);
      case AccessibilityFont.openSans:
        return GoogleFonts.openSansTextTheme(base);
      case AccessibilityFont.atkinson:
        return GoogleFonts.atkinsonHyperlegibleTextTheme(base);
      case AccessibilityFont.plusJakarta:
        return GoogleFonts.plusJakartaSansTextTheme(base);
    }
  }

  ThemeData applyToTheme(ThemeData base) {
    final accent = accentColor;
    final borderWidth = useOutline.value ? 2.0 : 1.5;
    final borderColor = highContrast.value ? Colors.black : accent;

    var theme = base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        secondary: useAltAccent.value ? AppTheme.accentGreen : AppTheme.primaryBlue,
        tertiary: accentDark,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedItemColor: accent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: borderWidth + 0.5),
        ),
        labelStyle: const TextStyle(color: AppTheme.textDark),
        prefixIconColor: accent,
      ),
    );

    if (useOutline.value) {
      theme = theme.copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: accent,
            elevation: 0,
            side: BorderSide(color: accent, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: BorderSide(color: accent, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: accent, width: 2),
          ),
        ),
      );
    } else {
      theme = theme.copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    if (highContrast.value) {
      theme = theme.copyWith(
        scaffoldBackgroundColor: Colors.white,
        dividerColor: Colors.black,
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
        ),
      );
    }

    return theme;
  }
}
