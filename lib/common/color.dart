import 'package:flutter/material.dart';

const _seedPrimary = Color(0xff89b4f9); // unchanged — sky blue
const _seedSecondary = Color(0xffA78BFA); // soft violet, replaces the clashing pink
const _seedTertiary = Color(0xffFFAB00); // warm amber, unchanged — good complement

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedPrimary,
      brightness: Brightness.dark,

      // Surfaces stripped of blue saturation → near-black neutrals.
      // Primary (#89b4f9) now has real contrast to pop against these.
      surfaceContainerLowest: const Color(0xff07080F),
      // near-AMOLED black
      surfaceContainerLow: const Color(0xff0D0F18),
      surface: const Color(0xff111320),
      surfaceContainer: const Color(0xff171929),
      surfaceContainerHigh: const Color(0xff1D1F30),
      // lyrics card — dark enough for white text contrast
      surfaceContainerHighest: const Color(0xff232537),

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

  // light theme unchanged — surface shift only matters for dark
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
