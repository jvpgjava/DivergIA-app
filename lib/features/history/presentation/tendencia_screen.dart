import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/deriva_formatting.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/screen_back_header.dart';
import '../data/models/painel_tendencia.dart';
import '../data/models/ponto_tendencia.dart';
import 'tendencia_controller.dart';

const _mesesAbrev = [
  'Jan',
  'Fev',
  'Mar',
  'Abr',
  'Mai',
  'Jun',
  'Jul',
  'Ago',
  'Set',
  'Out',
  'Nov',
  'Dez',
];

String _rotuloMes(String mes) {
  final partes = mes.split('-');
  if (partes.length != 2) return mes;
  final indice = int.tryParse(partes[1]);
  if (indice == null || indice < 1 || indice > 12) return mes;
  return _mesesAbrev[indice - 1];
}

/// Tela "Painel de Tendência Pessoal" — Fase 7. Sem referência no Figma
/// original (roadmap explicitamente marca essa tela como sem design de
/// referência); segue a linguagem visual das demais telas (cards brancos
/// arredondados, cabeçalho com botão de voltar, paleta do tema).
class TendenciaScreen extends ConsumerWidget {
  const TendenciaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tendenciaControllerProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.screenBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            const ScreenBackHeader(
              titulo: 'Painel de tendência',
              tituloFontSize: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Text(
                'Evolução das suas análises ao longo do tempo',
                style: AppTypography.body(context),
              ),
            ),
            const SizedBox(height: 16),
            if (state.loading)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(context),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          ref.read(tendenciaControllerProvider.notifier).carregar(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            else
              _Conteudo(painel: state.painel!),
          ],
        ),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.painel});

  final PainelTendencia painel;

  @override
  Widget build(BuildContext context) {
    if (painel.totalAnalises == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          'Ainda não há análises suficientes para montar seu painel de '
          'tendência. Volte aqui depois de analisar alguns textos.',
          textAlign: TextAlign.center,
          style: AppTypography.body(context),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeSlideIn(
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  rotulo: 'Análises',
                  valor: '${painel.totalAnalises}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  rotulo: 'Divergências',
                  valor: '${painel.totalDerivas}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  rotulo: 'Intensidade média',
                  valor: '${(painel.intensidadeMedia * 100).round()} pts',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          atraso: atrasoEmCascata(1),
          child: _EvolucaoCard(pontos: painel.evolucaoMensal),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          atraso: atrasoEmCascata(2),
          child: _DistribuicaoCard(derivasPorTipo: painel.derivasPorTipo),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: AppTypography.titleMedium(context).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(rotulo, style: AppTypography.caption(context)),
        ],
      ),
    );
  }
}

class _EvolucaoCard extends StatelessWidget {
  const _EvolucaoCard({required this.pontos});

  final List<PontoTendencia> pontos;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intensidade média por mês',
            style: AppTypography.cardTitle(context),
          ),
          const SizedBox(height: 16),
          if (pontos.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Ainda não há meses suficientes pra mostrar uma evolução '
                '(mínimo de 2).',
                style: AppTypography.body(context),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (pontos.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    horizontalInterval: 25,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: colors.border, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 25,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: AppTypography.caption(context),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final indice = value.round();
                          if (indice < 0 || indice >= pontos.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _rotuloMes(pontos[indice].mes),
                              style: AppTypography.caption(context),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < pontos.length; i++)
                          FlSpot(i.toDouble(), pontos[i].intensidadeMedia * 100),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colors.primaryTint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DistribuicaoCard extends StatelessWidget {
  const _DistribuicaoCard({required this.derivasPorTipo});

  final Map<String, int> derivasPorTipo;

  @override
  Widget build(BuildContext context) {
    final total = derivasPorTipo.values.fold<int>(0, (a, b) => a + b);
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Divergências por tipo',
            style: AppTypography.cardTitle(context),
          ),
          const SizedBox(height: 12),
          if (total == 0)
            Text(
              'Nenhuma divergência registrada ainda.',
              style: AppTypography.body(context),
            )
          else
            for (final tipo in const ['SENTIDO', 'POSICAO', 'INTENSIDADE'])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BarraDeTipo(
                  rotulo: rotuloTipoDesvio(tipo),
                  quantidade: derivasPorTipo[tipo] ?? 0,
                  proporcao: total == 0
                      ? 0
                      : (derivasPorTipo[tipo] ?? 0) / total,
                ),
              ),
        ],
      ),
    );
  }
}

class _BarraDeTipo extends StatelessWidget {
  const _BarraDeTipo({
    required this.rotulo,
    required this.quantidade,
    required this.proporcao,
  });

  final String rotulo;
  final int quantidade;
  final double proporcao;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(rotulo, style: AppTypography.body(context)),
            Text('$quantidade', style: AppTypography.bodyEmphasis(context)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: proporcao,
            minHeight: 6,
            backgroundColor: colors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
