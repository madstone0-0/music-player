import 'package:flutter/material.dart';

const _seedPrimary = Color(0xff89b4f9);
const _seedSecondary = Color(0xffC2185B);
const _seedTertiary = Color(0xffFFAB00);

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedPrimary,
      brightness: Brightness.dark,

      surface: const Color(0xff1E2235),
      surfaceContainerLowest: const Color(0xff181B2C),
      surfaceContainerLow: const Color(0xff1E2235),
      surfaceContainer: const Color(0xff252840),
      surfaceContainerHigh: const Color(0xff2C3050),
      surfaceContainerHighest: const Color(0xff383B49),

      primary: _seedPrimary,
      secondary: _seedSecondary,
      tertiary: _seedTertiary,
      error: const Color(0xffCF6679),
    );

    return _buildTheme(scheme).copyWith(
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: TextStyle(
          fontFamily: 'Circular Std',
          color: scheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedPrimary,
      brightness: Brightness.light,
      primary: _seedPrimary,
      secondary: _seedSecondary,
      tertiary: _seedTertiary,
    );

    return _buildTheme(scheme).copyWith(
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: TextStyle(
          fontFamily: 'Circular Std',
          color: scheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Shared component-level theme configuration.  Each getter above applies it
  /// then overrides the brightness-specific surface/appBar colours with copyWith.
  static ThemeData _buildTheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Circular Std',

      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: TextStyle(
          fontFamily: 'Circular Std',
          color: scheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(fontFamily: 'Circular Std', color: scheme.onSurfaceVariant, fontSize: 12),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.primary.withValues(alpha: 0.2),
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _seedPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _seedPrimary.withValues(alpha: 0.3),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Circular Std', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          textStyle: const TextStyle(fontFamily: 'Circular Std', fontSize: 14),
        ),
      ),

      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        overlayColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.04)),
        side: WidgetStatePropertyAll(BorderSide(color: scheme.outline.withValues(alpha: 0.3))),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        hintStyle: WidgetStatePropertyAll(TextStyle(color: scheme.onSurfaceVariant, fontSize: 14)),
        textStyle: WidgetStatePropertyAll(TextStyle(color: scheme.onSurface, fontSize: 14, fontFamily: 'Circular Std')),
      ),

      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.4), thickness: 1, space: 32),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(fontFamily: 'Circular Std', color: scheme.onSurface, fontSize: 13),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.08),
        circularTrackColor: scheme.primary.withValues(alpha: 0.12),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          highlightColor: scheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}

class AppColor {
  AppColor._();

  // Derive from the dark scheme so the values stay in sync.
  static final _scheme = AppTheme.dark.colorScheme;

  static Color get primary => _scheme.primary;

  static Color get focus => _scheme.primary; // was 0xffD9519D
  static Color get unfocused => _scheme.onSurfaceVariant;

  static Color get focusStart => _scheme.tertiary; // was 0xffED8770
  static Color get secondaryEnd => _scheme.secondary; // was 0xff657DDF
  static Color get org => const Color(0xffE1914B); // no M3 role — keep as-is

  static Color get primaryText => _scheme.onSurface;

  static Color get primaryText80 => _scheme.onSurface.withValues(alpha: 0.8);

  static Color get primaryText60 => _scheme.onSurface.withValues(alpha: 0.6);

  static Color get primaryText35 => _scheme.onSurface.withValues(alpha: 0.35);

  static Color get primaryText28 => _scheme.onSurface.withValues(alpha: 0.28);

  static Color get secondaryText => _scheme.onSurfaceVariant;

  static Color get bg => _scheme.surfaceContainerLowest;

  static Color get darkGray => _scheme.surfaceContainerHighest;

  static Color get lightGray => _scheme.outlineVariant;

  static List<Color> get primaryG => [focusStart, focus];

  static List<Color> get secondaryG => [primary, secondaryEnd];
}

// ─── HexColor extension (unchanged) ─────────────────────────────────────────

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
