import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_tokens.dart';

abstract final class AppTypography {
  static TextStyle displayLarge(BuildContext context) => GoogleFonts.sora(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: context.colors.textPrimary,
  );

  static TextStyle titleLarge(BuildContext context) => GoogleFonts.sora(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
  );

  static TextStyle titleMedium(BuildContext context) => GoogleFonts.sora(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
  );

  static TextStyle label(BuildContext context) => GoogleFonts.sora(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: context.colors.textLabel,
  );

  static TextStyle cardTitle(BuildContext context) => GoogleFonts.sora(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
  );

  static TextStyle get scoreBadge =>
      GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700);

  static TextStyle get buttonText => GoogleFonts.sora(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle body(BuildContext context) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: context.colors.textSecondary,
  );

  static TextStyle bodyEmphasis(BuildContext context) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: context.colors.textPrimary,
  );

  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: context.colors.textSecondary,
  );

  static TextStyle navLabel(BuildContext context) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: context.colors.textSecondary,
  );
}
