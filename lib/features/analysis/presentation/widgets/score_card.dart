import 'package:flutter/material.dart';

import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/deriva_formatting.dart';

/// "Score-Card" do Figma ("analysis-results"): medidor circular com a
/// pontuação de intensidade + título/descrição da divergência principal.
class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.pontuacao,
    required this.tipoDesvio,
  });

  final int pontuacao;
  final String tipoDesvio;

  @override
  Widget build(BuildContext context) {
    final cor = corDaPontuacao(context, pontuacao);
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pontuacao.toDouble()),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, valorAnimado, _) => Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: valorAnimado / 100,
                    strokeWidth: 6,
                    backgroundColor: colors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(cor.fg),
                  ),
                  Text(
                    '${valorAnimado.round()}',
                    style: AppTypography.titleMedium(
                      context,
                    ).copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tituloBriefing(tipoDesvio, pontuacao),
                  style: AppTypography.cardTitle(context),
                ),
                const SizedBox(height: 4),
                Text(
                  descricaoBriefing(tipoDesvio),
                  style: AppTypography.body(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
