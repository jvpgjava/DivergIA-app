import 'package:flutter/material.dart';

/// Cores de marca/estado extraídas do Figma que se mantêm IDÊNTICAS entre
/// claro e escuro (confirmado comparando "profile-settings" com
/// "profile-settings-dark": vermelho/ciano continuam o mesmo tom nos dois
/// temas). Tokens que mudam entre os temas (fundo, borda, texto...) ficam
/// em [AppColorTokens] — acessível via `context.colors`.
abstract final class AppColors {
  static const Color primary = Color(0xFF26C6FF);
  static const Color primaryGradientEnd = Color(0xFF66D9FF);
  static const Color primaryShadow = Color(0x3326C6FF);

  static const Color danger = Color(0xFFEF4444);

  // Score-Badge do histórico — a cor varia com a severidade da divergência.
  // Só o "Fg" (texto/ícone) é fixo — o "Bg" muda com o tema, ver
  // [AppColorTokens.scoreAltoBg] etc.
  static const Color scoreAltoFg = Color(0xFFEF4444);
  static const Color scoreMedioFg = Color(0xFFF59E0B);
  static const Color scoreBaixoFg = Color(0xFF10B981);

  // Explanation-Banner do resultado da análise — Figma: "analysis-results".
  static const Color explanationBannerFg = Color(0xFFD9381E);

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment(-0.15, -1),
    end: Alignment(0.15, 1),
    colors: [primary, primaryGradientEnd],
  );
}
