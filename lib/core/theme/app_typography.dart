import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Escala tipográfica extraída do protótipo Figma: títulos em Sora
/// (ExtraBold/SemiBold), corpo/rótulos em Inter (Regular/Medium/SemiBold).
abstract final class AppTypography {
  static TextStyle get displayLarge => GoogleFonts.sora(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.sora(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.sora(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get label => GoogleFonts.sora(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textLabel,
  );

  static TextStyle get buttonText => GoogleFonts.sora(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodyEmphasis => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get navLabel => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}
