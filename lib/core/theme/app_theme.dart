import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Tema base do app, construído a partir dos tokens extraídos do Figma
/// (ver [AppColors] e [AppTypography]) — nenhuma tela deve declarar cor ou
/// fonte "solta", sempre via [ThemeData]/[Theme.of(context)].
abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.body.fontFamily,
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        labelLarge: AppTypography.label,
        bodyLarge: AppTypography.bodyEmphasis,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: AppTypography.body,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      dividerColor: AppColors.border,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.titleMedium,
      ),
    );
  }
}
