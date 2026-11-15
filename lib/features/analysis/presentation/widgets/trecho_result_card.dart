import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/deriva_formatting.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/models/trecho_deriva.dart';

class TrechoResultCard extends StatelessWidget {
  const TrechoResultCard({
    super.key,
    required this.trecho,
    required this.onSugerirReescrita,
    this.textoOriginalCompleto,
    this.textoEditadoCompleto,
  });

  final TrechoDeriva trecho;
  final String? textoOriginalCompleto;
  final String? textoEditadoCompleto;
  final VoidCallback onSugerirReescrita;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Painel(
          rotulo: 'TEXTO ORIGINAL',
          textoCompleto: textoOriginalCompleto,
          trechoDestacado: trecho.trechoOriginal,
        ),
        const SizedBox(height: 8),
        _Painel(
          rotulo: 'TEXTO EDITADO',
          textoCompleto: textoEditadoCompleto,
          trechoDestacado: trecho.trechoEditado,
        ),
        const SizedBox(height: 12),
        _ExplanationBanner(trecho: trecho),
        if (trecho.sugestaoAceita != null) ...[
          const SizedBox(height: 12),
          _SugestaoAceitaPainel(texto: trecho.sugestaoAceita!),
        ],
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Sugerir reescrita fiel',
          onPressed: onSugerirReescrita,
        ),
      ],
    );
  }
}

class _Painel extends StatelessWidget {
  const _Painel({
    required this.rotulo,
    required this.textoCompleto,
    required this.trechoDestacado,
  });

  final String rotulo;
  final String? textoCompleto;
  final String trechoDestacado;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseStyle = AppTypography.bodyEmphasis(
      context,
    ).copyWith(color: colors.textPrimary);
    final highlightStyle = baseStyle.copyWith(
      color: AppColors.explanationBannerFg,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.explanationBannerFg,
    );

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
          Text.rich(
            TextSpan(
              children: _spansDestacados(
                textoCompleto: textoCompleto,
                trecho: trechoDestacado,
                baseStyle: baseStyle,
                highlightStyle: highlightStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _spansDestacados({
    required String? textoCompleto,
    required String trecho,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
  }) {
    if (textoCompleto == null) {
      return [TextSpan(text: trecho, style: highlightStyle)];
    }
    final indice = textoCompleto.indexOf(trecho);
    if (indice == -1) {
      return [TextSpan(text: trecho, style: highlightStyle)];
    }
    return [
      TextSpan(text: textoCompleto.substring(0, indice), style: baseStyle),
      TextSpan(
        text: textoCompleto.substring(indice, indice + trecho.length),
        style: highlightStyle,
      ),
      TextSpan(
        text: textoCompleto.substring(indice + trecho.length),
        style: baseStyle,
      ),
    ];
  }
}

class _SugestaoAceitaPainel extends StatelessWidget {
  const _SugestaoAceitaPainel({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUGESTÃO ACEITA',
            style: AppTypography.caption(context).copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            texto,
            style: AppTypography.bodyEmphasis(
              context,
            ).copyWith(color: colors.textPrimary),
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
