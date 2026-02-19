import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static const Color _seed = Color(0xFF6366F1);

  /// Broadcast-dark background target (~ #0F1115).
  static const Color _background = Color(0xFF0F1115);
  static const Color _surface = Color(0xFF141823);

  static ThemeData dark() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );

    final scheme = baseScheme.copyWith(
      surface: _surface,
      surfaceContainerHighest: const Color(0xFF1A2030),
      surfaceContainerHigh: const Color(0xFF161C2A),
      surfaceContainer: _surface,
      surfaceContainerLow: const Color(0xFF121623),
      surfaceContainerLowest: _background,
    );

    final baseTextTheme = Typography.material2021(platform: TargetPlatform.android)
        .black
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final uiTextTheme = GoogleFonts.notoSansKrTextTheme(baseTextTheme);
    final mono = GoogleFonts.jetBrainsMonoTextTheme(baseTextTheme);

    // Keep Material scale, but force monospace for timecode-style slots.
    final merged = uiTextTheme.copyWith(
      displayLarge: mono.displayLarge,
      displayMedium: mono.displayMedium,
      displaySmall: mono.displaySmall,
      headlineLarge: uiTextTheme.headlineLarge,
      headlineMedium: uiTextTheme.headlineMedium,
      headlineSmall: uiTextTheme.headlineSmall,
      titleLarge: uiTextTheme.titleLarge,
      titleMedium: uiTextTheme.titleMedium,
      titleSmall: uiTextTheme.titleSmall,
      bodyLarge: uiTextTheme.bodyLarge,
      bodyMedium: uiTextTheme.bodyMedium,
      bodySmall: uiTextTheme.bodySmall,
      labelLarge: uiTextTheme.labelLarge,
      labelMedium: uiTextTheme.labelMedium,
      labelSmall: uiTextTheme.labelSmall,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: _background,
      textTheme: merged,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        contentTextStyle: merged.bodyMedium?.copyWith(color: scheme.onSurface),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
    );
  }
}

