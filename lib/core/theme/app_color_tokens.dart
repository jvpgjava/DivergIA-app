import 'package:flutter/material.dart';

/// Tokens de cor que MUDAM entre claro/escuro (fundo, borda, texto...) —
/// extraídos dos pares de frame do Figma ("profile-settings" /
/// "profile-settings-dark"). Cores de marca/estado (primary, danger,
/// score*, explanationBanner*) não entram aqui: o Figma mostra que elas se
/// mantêm idênticas nos dois temas, então continuam em [AppColors] como
/// constantes fixas.
///
/// Acesse sempre via `context.colors.xxx` (ver [AppColorTokensX]), nunca
/// instanciando ou importando `light`/`dark` diretamente fora do
/// [core/theme/app_theme.dart].
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.background,
    required this.surfaceInput,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLabel,
    required this.screenBackground,
    required this.primaryTint,
    required this.scoreAltoBg,
    required this.scoreMedioBg,
    required this.scoreBaixoBg,
    required this.explanationBannerBg,
    required this.highContrastSurface,
  });

  final Color background;
  final Color surfaceInput;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textLabel;
  final Color screenBackground;
  final Color primaryTint;

  // Fundos de estado (Score-Badge, Explanation-Banner) — no Figma claro são
  // um tom pastel sólido; no escuro viram o próprio tom "Fg" em baixa
  // opacidade (mesmo padrão observado no Avatar-Card: `primaryTint` sólido
  // no claro vira `primary` a 10% no escuro). Os "Fg" continuam fixos em
  // [AppColors] — só o fundo muda.
  final Color scoreAltoBg;
  final Color scoreMedioBg;
  final Color scoreBaixoBg;
  final Color explanationBannerBg;

  /// Fundo de botão-ícone que precisa de bastante contraste sobre o
  /// próprio fundo do tema (ex.: "Tab-Add" do Bottom-Nav) — no claro é o
  /// mesmo tom escuro de `textPrimary`, mas no escuro o Figma troca para um
  /// ciano vibrante em vez de repetir `textPrimary` (que no escuro é quase
  /// branco, e ficaria sem contraste com o ícone branco por cima).
  final Color highContrastSurface;

  static const light = AppColorTokens(
    background: Color(0xFFFFFFFF),
    surfaceInput: Color(0xFFF8FAFC),
    border: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0D182A),
    textSecondary: Color(0xFF64748B),
    textLabel: Color(0xFF1B3440),
    screenBackground: Color(0xFFF8FAFC),
    primaryTint: Color(0xFFE6F7FF),
    scoreAltoBg: Color(0xFFFEE2E2),
    scoreMedioBg: Color(0xFFFEF3C7),
    scoreBaixoBg: Color(0xFFD1FAE5),
    explanationBannerBg: Color(0xFFFFEBE6),
    highContrastSurface: Color(0xFF0D182A),
  );

  static const dark = AppColorTokens(
    background: Color(0xFF141B2D),
    surfaceInput: Color(0xFF090D16),
    border: Color(0xFF222F47),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textLabel: Color(0xFFF8FAFC),
    screenBackground: Color(0xFF090D16),
    primaryTint: Color(0x1A26C6FF),
    scoreAltoBg: Color(0x1AEF4444),
    scoreMedioBg: Color(0x1AF59E0B),
    scoreBaixoBg: Color(0x1A10B981),
    explanationBannerBg: Color(0x1AD9381E),
    highContrastSurface: Color(0xFF00C0E8),
  );

  @override
  AppColorTokens copyWith({
    Color? background,
    Color? surfaceInput,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textLabel,
    Color? screenBackground,
    Color? primaryTint,
    Color? scoreAltoBg,
    Color? scoreMedioBg,
    Color? scoreBaixoBg,
    Color? explanationBannerBg,
    Color? highContrastSurface,
  }) {
    return AppColorTokens(
      background: background ?? this.background,
      surfaceInput: surfaceInput ?? this.surfaceInput,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textLabel: textLabel ?? this.textLabel,
      screenBackground: screenBackground ?? this.screenBackground,
      primaryTint: primaryTint ?? this.primaryTint,
      scoreAltoBg: scoreAltoBg ?? this.scoreAltoBg,
      scoreMedioBg: scoreMedioBg ?? this.scoreMedioBg,
      scoreBaixoBg: scoreBaixoBg ?? this.scoreBaixoBg,
      explanationBannerBg: explanationBannerBg ?? this.explanationBannerBg,
      highContrastSurface: highContrastSurface ?? this.highContrastSurface,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      background: Color.lerp(background, other.background, t)!,
      surfaceInput: Color.lerp(surfaceInput, other.surfaceInput, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textLabel: Color.lerp(textLabel, other.textLabel, t)!,
      screenBackground: Color.lerp(screenBackground, other.screenBackground, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      scoreAltoBg: Color.lerp(scoreAltoBg, other.scoreAltoBg, t)!,
      scoreMedioBg: Color.lerp(scoreMedioBg, other.scoreMedioBg, t)!,
      scoreBaixoBg: Color.lerp(scoreBaixoBg, other.scoreBaixoBg, t)!,
      explanationBannerBg:
          Color.lerp(explanationBannerBg, other.explanationBannerBg, t)!,
      highContrastSurface:
          Color.lerp(highContrastSurface, other.highContrastSurface, t)!,
    );
  }
}

extension AppColorTokensX on BuildContext {
  AppColorTokens get colors => Theme.of(this).extension<AppColorTokens>()!;
}
