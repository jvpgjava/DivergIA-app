import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/deriva_formatting.dart';
import '../../data/models/analise_resumo.dart';

/// Card de uma análise na lista de histórico — Figma: "History-Card".
class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.analise, required this.onTap});

  final AnaliseResumo analise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pontuacao = analise.pontuacaoIntensidade;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rotuloTipoDesvio(analise.tipoDesvioPrincipal),
                        style: AppTypography.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatarDataRelativa(analise.criadoEm),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                if (pontuacao != null) ...[
                  const SizedBox(width: 8),
                  _ScoreBadge(pontuacao: pontuacao),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              analise.textoPreview ?? 'Texto não salvo (histórico não retido).',
              style: AppTypography.body.copyWith(
                color: AppColors.textLabel,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pontuacao != null
                        ? 'Divergência Analisada'
                        : 'Sem detalhes salvos',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver detalhes',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.arrowRight,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.pontuacao});

  final int pontuacao;

  @override
  Widget build(BuildContext context) {
    final cor = corDaPontuacao(pontuacao);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$pontuacao pts',
        style: AppTypography.scoreBadge.copyWith(color: cor.fg),
      ),
    );
  }
}
