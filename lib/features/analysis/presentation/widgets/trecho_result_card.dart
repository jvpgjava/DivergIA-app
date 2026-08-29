import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/deriva_formatting.dart';
import '../../data/models/trecho_deriva.dart';

/// "Comparison-Stack" + "Explanation-Banner" do Figma ("analysis-results"),
/// repetidos uma vez por trecho de deriva de uma análise.
///
/// O Figma sublinha só a frase específica que mudou dentro de uma frase
/// maior, mas o backend só entrega o trecho isolado (não o texto ao redor),
/// então aqui o trecho inteiro é destacado — é o mais fiel possível ao dado
/// real disponível.
class TrechoResultCard extends StatelessWidget {
  const TrechoResultCard({
    super.key,
    required this.trecho,
    required this.onSugerirReescrita,
  });

  final TrechoDeriva trecho;
  final VoidCallback onSugerirReescrita;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Painel(rotulo: 'TEXTO ORIGINAL', texto: trecho.trechoOriginal),
        const SizedBox(height: 8),
        _Painel(rotulo: 'TEXTO EDITADO', texto: trecho.trechoEditado),
        const SizedBox(height: 12),
        _ExplanationBanner(trecho: trecho),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onSugerirReescrita,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textPrimary,
              side: BorderSide(color: colors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: Text(
              'Sugerir reescrita fiel',
              style: AppTypography.label(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _Painel extends StatelessWidget {
  const _Painel({required this.rotulo, required this.texto});

  final String rotulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: AppTypography.caption(
              context,
            ).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.4),
          ),
          const SizedBox(height: 6),
          Text(
            texto,
            style: AppTypography.bodyEmphasis(context).copyWith(
              color: AppColors.explanationBannerFg,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.explanationBannerFg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationBanner extends StatelessWidget {
  const _ExplanationBanner({required this.trecho});

  final TrechoDeriva trecho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.explanationBannerBg,
        border: Border.all(color: AppColors.explanationBannerFg),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.alertCircle,
            size: 20,
            color: AppColors.explanationBannerFg,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotuloTipoDesvio(trecho.tipoDesvio),
                  style: AppTypography.cardTitle(
                    context,
                  ).copyWith(color: AppColors.explanationBannerFg),
                ),
                const SizedBox(height: 4),
                Text(
                  trecho.explicacao,
                  style: AppTypography.body(
                    context,
                  ).copyWith(color: AppColors.explanationBannerFg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
