import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  // Keys for the on-device GetStorage box. Settings persist across app
  // restarts (and even reinstalling on the same device keeps them, since
  // GetStorage writes to app-private storage, not memory).
  static const _kOutline = 'a11y_outline';
  static const _kAltAccent = 'a11y_alt_accent';
  static const _kReduceOpacity = 'a11y_reduce_opacity';
  static const _kOpacityLevel = 'a11y_opacity_level';
  static const _kHighContrast = 'a11y_high_contrast';
  static const _kFont = 'a11y_font';
  static const _kFontScale = 'a11y_font_scale';
  static const _kOffsetX = 'a11y_offset_x';
  static const _kOffsetY = 'a11y_offset_y';

  final _box = GetStorage();

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

  /// True while the button is actively being dragged, so the UI can skip
  /// position animation and track the finger/cursor 1:1.
  final isDragging = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  void _restore() {
    useOutline.value = _box.read<bool>(_kOutline) ?? useOutline.value;
    useAltAccent.value = _box.read<bool>(_kAltAccent) ?? useAltAccent.value;
    reduceOpacity.value =
        _box.read<bool>(_kReduceOpacity) ?? reduceOpacity.value;
    opacityLevel.value =
        (_box.read<num>(_kOpacityLevel) ?? opacityLevel.value).toDouble();
    highContrast.value = _box.read<bool>(_kHighContrast) ?? highContrast.value;
    fontScale.value = (_box.read<num>(_kFontScale) ?? fontScale.value).toDouble();
    final storedFont = _box.read<String>(_kFont);
    selectedFont.value = AccessibilityFont.values.firstWhere(
      (f) => f.name == storedFont,
      orElse: () => selectedFont.value,
    );
    final storedX = _box.read<num>(_kOffsetX);
    final storedY = _box.read<num>(_kOffsetY);
    if (storedX != null) offsetX.value = storedX.toDouble();
    if (storedY != null) offsetY.value = storedY.toDouble();
  }

  Color get accentColor =>
      useAltAccent.value ? AppTheme.primaryBlue : AppTheme.accentGreen;

  Color get accentDark =>
      useAltAccent.value ? AppTheme.primaryDark : AppTheme.accentGreenDark;

  LinearGradient get accentGradient => LinearGradient(
        colors: useAltAccent.value
            ? const [AppTheme.lightCyan, AppTheme.primaryBlue]
            : [AppTheme.primaryBlue, AppTheme.accentGreen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  void togglePanel() => isPanelOpen.value = !isPanelOpen.value;

  void closePanel() => isPanelOpen.value = false;

  void setOutline(bool value) {
    useOutline.value = value;
    _box.write(_kOutline, value);
  }

  void setAltAccent(bool value) {
    useAltAccent.value = value;
    _box.write(_kAltAccent, value);
  }

  void setOpacityEnabled(bool value) {
    reduceOpacity.value = value;
    _box.write(_kReduceOpacity, value);
  }

  void setOpacityLevel(double value) {
    opacityLevel.value = value.clamp(0.5, 1.0);
    _box.write(_kOpacityLevel, opacityLevel.value);
  }

  void setHighContrast(bool value) {
    highContrast.value = value;
    _box.write(_kHighContrast, value);
  }

  void setFont(AccessibilityFont font) {
    selectedFont.value = font;
    _box.write(_kFont, font.name);
  }

  void setFontScale(double value) {
    fontScale.value = value.clamp(0.85, 1.5);
    _box.write(_kFontScale, fontScale.value);
  }

  void updatePosition(double dx, double dy, Size screenSize) {
    const fabSize = 56.0;
    const margin = 8.0;
    offsetX.value =
        (offsetX.value - dx).clamp(margin, screenSize.width - fabSize - margin);
    offsetY.value = (offsetY.value - dy)
        .clamp(margin, screenSize.height - fabSize - margin);
  }

  /// Snaps the button horizontally to whichever edge (left or right) it
  /// ended up closest to when the drag was released, Messenger-chat-head
  /// style. Vertical position is left where the user dropped it.
  void snapToNearestEdge(Size screenSize) {
    const fabSize = 56.0;
    const margin = 8.0;
    final maxOffsetX =
        (screenSize.width - fabSize - margin).clamp(margin, double.infinity);
    final midpoint = maxOffsetX / 2;
    offsetX.value = offsetX.value <= midpoint ? margin : maxOffsetX;
    _box.write(_kOffsetX, offsetX.value);
    _box.write(_kOffsetY, offsetY.value);
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

    // The "Outline" accessibility toggle intentionally reverts to a more
    // visible bordered input style for low-vision users. Outside of that,
    // keep the app's modern borderless/filled input theme and just retint
    // the focus ring to match the selected accent color.
    final inputTheme = useOutline.value
        ? InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: AppTheme.br16,
              borderSide: BorderSide(color: borderColor, width: borderWidth),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppTheme.br16,
              borderSide: BorderSide(color: borderColor, width: borderWidth),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppTheme.br16,
              borderSide: BorderSide(color: accent, width: borderWidth + 0.5),
            ),
            labelStyle: const TextStyle(color: AppTheme.textDark),
            prefixIconColor: accent,
          )
        : base.inputDecorationTheme.copyWith(
            focusedBorder: OutlineInputBorder(
              borderRadius: AppTheme.br16,
              borderSide: BorderSide(color: accent, width: 1.8),
            ),
            floatingLabelStyle: TextStyle(color: accent),
            prefixIconColor: accent,
          );

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
      inputDecorationTheme: inputTheme,
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
