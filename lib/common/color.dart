import 'package:flutter/material.dart';

// ─── Seed colors ──────────────────────────────────────────────────────────────
// One primary seed drives the entire tonal palette via M3's HCT algorithm.
// The custom surface/background pins keep the dark UI you already have.

const _seedPrimary   = Color(0xff2979FF); // HCT hue ≈ 255 — electric blue
const _seedSecondary = Color(0xffC2185B); // HCT hue ≈ 340 — deep magenta
const _seedTertiary  = Color(0xffFFAB00); // HCT hue ≈  45 — gold

// ─── AppTheme ────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  /// Apply to GetMaterialApp / MaterialApp as [theme] + [darkTheme],
  /// then set [themeMode: ThemeMode.dark] (or .system).
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedPrimary,
      brightness: Brightness.dark,

      // Pin your existing surface stack so the generated palette
      // respects the dark navy you already use everywhere.
      surface: const Color(0xff1E2235),
      // slightly lighter than bg
      surfaceContainerLowest: const Color(0xff181B2C),
      // == your old AppColor.bg
      surfaceContainerLow: const Color(0xff1E2235),
      surfaceContainer: const Color(0xff252840),
      surfaceContainerHigh: const Color(0xff2C3050),
      surfaceContainerHighest: const Color(0xff383B49),
      // == your old darkGray

      // Accent roles — let M3 derive these from the seed but override
      // the ones that must match your brand exactly.
      primary: _seedPrimary,
      secondary: _seedSecondary,
      tertiary: _seedTertiary,
      error: const Color(0xffCF6679),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Circular Std',

      // ── Scaffold / background ─────────────────────────────────────────────
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,

      // ── AppBar ────────────────────────────────────────────────────────────
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

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── ListTile ─────────────────────────────────────────────────────────
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

      // ── Slider ────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.primary.withOpacity(0.2),
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withOpacity(0.12),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),

      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _seedPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _seedPrimary.withOpacity(0.3),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Circular Std', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ── TextButton ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          textStyle: const TextStyle(fontFamily: 'Circular Std', fontSize: 14),
        ),
      ),

      // ── SearchBar ─────────────────────────────────────────────────────────
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        overlayColor: WidgetStatePropertyAll(scheme.onSurface.withOpacity(0.04)),
        side: WidgetStatePropertyAll(BorderSide(color: scheme.outline.withOpacity(0.3))),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        hintStyle: WidgetStatePropertyAll(TextStyle(color: scheme.onSurfaceVariant, fontSize: 14)),
        textStyle: WidgetStatePropertyAll(TextStyle(color: scheme.onSurface, fontSize: 14, fontFamily: 'Circular Std')),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withOpacity(0.4), thickness: 1, space: 32),

      // ── BottomSheet ───────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),

      // ── PopupMenu ─────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(fontFamily: 'Circular Std', color: scheme.onSurface, fontSize: 13),
      ),

      // ── CircularProgressIndicator ────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withOpacity(0.08),
        circularTrackColor: scheme.primary.withOpacity(0.12),
      ),

      // ── IconButton ────────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          highlightColor: scheme.onSurface.withOpacity(0.08),
        ),
      ),
    );
  }

  /// Light variant — same seed, different brightness.
  /// Wire to MaterialApp.theme if you want system-adaptive theming.
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedPrimary,
      brightness: Brightness.light,
      primary: _seedPrimary,
      secondary: _seedSecondary,
      tertiary: _seedTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Circular Std',
      scaffoldBackgroundColor: scheme.surface,
    );
  }
}

// ─── AppColor ────────────────────────────────────────────────────────────────
// Kept as a compatibility shim so existing widgets that reference AppColor
// don't break while you migrate them to Theme.of(context).colorScheme.
// Migrate call sites one screen at a time, then delete this class.

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

  static Color get primaryText80 => _scheme.onSurface.withOpacity(0.8);

  static Color get primaryText60 => _scheme.onSurface.withOpacity(0.6);

  static Color get primaryText35 => _scheme.onSurface.withOpacity(0.35);

  static Color get primaryText28 => _scheme.onSurface.withOpacity(0.28);

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
