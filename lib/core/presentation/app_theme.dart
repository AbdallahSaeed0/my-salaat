import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern-minimal-dark design system: near-black surfaces, a single vivid
/// accent color, flat low-noise cards (hairline borders instead of heavy
/// elevation/shadow), and generous whitespace. The light theme mirrors the
/// same language (crisp near-white surfaces, same accent) rather than being
/// a separate look.
class AppTheme {
  AppTheme._();

  // Single accent color, used identically in both themes — the traditional
  // deep green seen on Mushaf (Quran) covers and Islamic branding, rather
  // than a bright/neon tone. Tuned slightly brighter than the deepest
  // Mushaf-cover shade so it stays legible as text/icons on the near-black
  // background (small text at pure #0E7C3A falls under WCAG AA contrast).
  static const _accent = Color(0xFF129E4C);

  static const _darkBackground = Color(0xFF0B0C0F);
  static const _darkSurface = Color(0xFF16171B);
  static const _lightBackground = Color(0xFFFAFAFA);
  static const _lightSurface = Color(0xFFFFFFFF);

  static ThemeData light() => _build(brightness: Brightness.light);

  static ThemeData dark() => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: brightness,
    ).copyWith(
      primary: _accent,
      surface: isDark ? _darkSurface : _lightSurface,
      surfaceContainerHighest: isDark ? const Color(0xFF1E2025) : const Color(0xFFF0F0F1),
      onSurfaceVariant: isDark ? const Color(0xFFA3A6AD) : const Color(0xFF6B6E76),
      outlineVariant: isDark ? const Color(0xFF2A2C32) : const Color(0xFFE4E4E6),
    );

    final baseTextTheme = GoogleFonts.manropeTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    final textTheme = baseTextTheme.copyWith(
      displaySmall: baseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.4),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      bodySmall: baseTextTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? _darkBackground : _lightBackground,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, thickness: 1, space: 32),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primary,
        labelStyle: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w700),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          side: WidgetStatePropertyAll(BorderSide(color: colorScheme.outlineVariant)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? colorScheme.primary : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? _darkBackground : _lightBackground,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.surfaceContainerHighest,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
