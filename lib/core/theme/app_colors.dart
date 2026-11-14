import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF26C6FF);
  static const Color primaryGradientEnd = Color(0xFF66D9FF);
  static const Color primaryShadow = Color(0x3326C6FF);

  static const Color danger = Color(0xFFEF4444);

  static const Color scoreAltoFg = Color(0xFFEF4444);
  static const Color scoreMedioFg = Color(0xFFF59E0B);
  static const Color scoreBaixoFg = Color(0xFF10B981);

  static const Color explanationBannerFg = Color(0xFFD9381E);

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment(-0.15, -1),
    end: Alignment(0.15, 1),
    colors: [primary, primaryGradientEnd],
  );
}
