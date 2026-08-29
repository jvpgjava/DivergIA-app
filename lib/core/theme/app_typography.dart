import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_tokens.dart';

/// Escala tipográfica extraída do protótipo Figma: títulos em Sora
/// (ExtraBold/SemiBold), corpo/rótulos em Inter (Regular/Medium/SemiBold).
///
/// A maioria dos estilos recebe `context` porque a cor (texto
/// primário/secundário) muda entre claro e escuro — só [scoreBadge] e
/// [buttonText] não mudam (cor sempre definida por quem usa, ou fixa em
/// branco sobre botão colorido).
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

  /// Título de card (ex: "History-Card" do histórico) — Sora Bold 15.
  static TextStyle cardTitle(BuildContext context) => GoogleFonts.sora(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
  );

  /// Texto do Score-Badge — Sora Bold 12, cor definida por quem usa.
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
