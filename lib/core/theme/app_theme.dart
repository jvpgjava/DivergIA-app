import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_tokens.dart';
import 'app_colors.dart';

/// Tema base do app, construído a partir dos tokens extraídos do Figma
/// (ver [AppColors]/[AppColorTokens] e [AppTypography]) — nenhuma tela deve
/// declarar cor ou fonte "solta", sempre via `context.colors`/
/// `AppTypography.xxx(context)`.
abstract final class AppTheme {
  static ThemeData get light => _build(AppColorTokens.light, Brightness.light);

  static ThemeData get dark => _build(AppColorTokens.dark, Brightness.dark);

  static ThemeData _build(AppColorTokens tokens, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: tokens.background,
      onSurface: tokens.textPrimary,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      extensions: [tokens],
      textTheme: TextTheme(
        displayLarge: GoogleFonts.sora(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: tokens.textPrimary,
        ),
        titleLarge: GoogleFonts.sora(
          fontSize: 23,
          fontWeight: FontWeight.w700,
          color: tokens.textPrimary,
        ),
        titleMedium: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: tokens.textPrimary,
        ),
        labelLarge: GoogleFonts.sora(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: tokens.textLabel,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: tokens.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: tokens.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: tokens.textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: tokens.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens.border),
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
      dividerColor: tokens.border,
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: tokens.textPrimary,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: tokens.textPrimary,
        ),
      ),
    );
  }
}
