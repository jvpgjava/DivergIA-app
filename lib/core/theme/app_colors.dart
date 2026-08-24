import 'package:flutter/material.dart';

/// Paleta extraída do protótipo Figma (arquivo "PrototipoTelas-DIvergIA").
/// Não hardcodar essas cores em widgets individuais — sempre referenciar
/// [AppColors] para manter uma única fonte de verdade.
abstract final class AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceInput = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF0D182A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLabel = Color(0xFF1B3440);

  static const Color primary = Color(0xFF26C6FF);
  static const Color primaryGradientEnd = Color(0xFF66D9FF);
  static const Color primaryShadow = Color(0x3326C6FF);

  static const Color danger = Color(0xFFEF4444);

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment(-0.15, -1),
    end: Alignment(0.15, 1),
    colors: [primary, primaryGradientEnd],
  );
}
