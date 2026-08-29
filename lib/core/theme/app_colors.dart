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

  /// Fundo geral de tela (distinto do branco dos cards) — Figma: "home-history".
  static const Color screenBackground = Color(0xFFF8FAFC);

  /// Mesmo azul-claro do checkbox marcado e da Status-Tag do histórico.
  static const Color primaryTint = Color(0xFFE6F7FF);

  // Score-Badge do histórico — a cor varia com a severidade da divergência.
  static const Color scoreAltoBg = Color(0xFFFEE2E2);
  static const Color scoreAltoFg = Color(0xFFEF4444);
  static const Color scoreMedioBg = Color(0xFFFEF3C7);
  static const Color scoreMedioFg = Color(0xFFF59E0B);
  static const Color scoreBaixoBg = Color(0xFFD1FAE5);
  static const Color scoreBaixoFg = Color(0xFF10B981);

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment(-0.15, -1),
    end: Alignment(0.15, 1),
    colors: [primary, primaryGradientEnd],
  );
}
