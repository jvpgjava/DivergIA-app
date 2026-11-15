import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/deriva_formatting.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/screen_back_header.dart';
import '../data/models/estatisticas_globais.dart';
import 'estatisticas_controller.dart';

const _corAnalises = AppColors.primary;
const _corDerivas = AppColors.scoreMedioFg;

class DevEstatisticasScreen extends ConsumerStatefulWidget {
  const DevEstatisticasScreen({super.key});

  @override
  ConsumerState<DevEstatisticasScreen> createState() =>
      _DevEstatisticasScreenState();
}

class _DevEstatisticasScreenState extends ConsumerState<DevEstatisticasScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Em segundo plano não há por que consultar o servidor a cada poucos segundos.
  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    final controller = ref.read(estatisticasControllerProvider.notifier);
    if (estado == AppLifecycleState.resumed) {
      controller.carregar(silencioso: true);
      controller.retomar();
    } else {
      controller.pausar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(estatisticasControllerProvider);
    final colors = context.colors;
    final estatisticas = state.estatisticas;

    return Scaffold(
      backgroundColor: colors.screenBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            const ScreenBackHeader(
              titulo: 'Painel de desenvolvedor',
              tituloFontSize: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Text(
                'Análises feitas por todos os usuários',
                style: AppTypography.body(context),
              ),
            ),
            const SizedBox(height: 16),
            if (estatisticas != null)
              _Conteudo(estatisticas: estatisticas, dias: state.dias)
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
                      onPressed: () => ref
                          .read(estatisticasControllerProvider.notifier)
                          .carregar(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Conteudo extends ConsumerWidget {
  const _Conteudo({required this.estatisticas, required this.dias});

  final EstatisticasGlobais estatisticas;
  final int dias;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final porAnalise = estatisticas.totalAnalises == 0
        ? 0.0
        : estatisticas.totalDerivas / estatisticas.totalAnalises;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeSlideIn(child: _TotalCard(estatisticas: estatisticas)),
        const SizedBox(height: 12),
        FadeSlideIn(
          atraso: atrasoEmCascata(1),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  chave: const Key('analises-hoje'),
                  rotulo: 'Hoje',
                  valor: '${estatisticas.analisesHoje}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  chave: const Key('total-derivas'),
                  rotulo: 'Divergências',
                  valor: '${estatisticas.totalDerivas}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  rotulo: 'Por análise',
                  valor: porAnalise.toStringAsFixed(1).replaceAll('.', ','),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          atraso: atrasoEmCascata(2),
          child: _EvolucaoCard(
            pontos: estatisticas.serieDiaria,
            dias: dias,
            aoEscolherPeriodo: (novo) => ref
                .read(estatisticasControllerProvider.notifier)
                .definirPeriodo(novo),
          ),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          atraso: atrasoEmCascata(3),
          child: _DistribuicaoCard(derivasPorTipo: estatisticas.derivasPorTipo),
        ),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.estatisticas});

  final EstatisticasGlobais estatisticas;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final atualizado = estatisticas.geradoEm.toLocal();
    final hora = [
      atualizado.hour,
      atualizado.minute,
      atualizado.second,
    ].map((n) => n.toString().padLeft(2, '0')).join(':');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PontoAoVivo(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ao vivo · atualizado às $hora',
                  style: AppTypography.caption(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Anima de um valor para o outro quando chega uma análise nova.
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: estatisticas.totalAnalises.toDouble()),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, valor, _) => Text(
              '${valor.round()}',
              key: const Key('total-analises'),
              style: AppTypography.titleMedium(context).copyWith(fontSize: 44),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'análises realizadas no total',
            style: AppTypography.body(context),
          ),
          const SizedBox(height: 4),
          Text(
            'Conta também as análises que os usuários já apagaram.',
            style: AppTypography.caption(context),
          ),
        ],
      ),
    );
  }
}

class _PontoAoVivo extends StatefulWidget {
  const _PontoAoVivo();

  @override
  State<_PontoAoVivo> createState() => _PontoAoVivoState();
}

class _PontoAoVivoState extends State<_PontoAoVivo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.scoreBaixoFg,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({this.chave, required this.rotulo, required this.valor});

  final Key? chave;
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
            key: chave,
            style: AppTypography.titleMedium(context).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              rotulo,
              softWrap: false,
              style: AppTypography.caption(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvolucaoCard extends StatelessWidget {
  const _EvolucaoCard({
    required this.pontos,
    required this.dias,
    required this.aoEscolherPeriodo,
  });

  final List<PontoDiario> pontos;
  final int dias;
  final void Function(int dias) aoEscolherPeriodo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maiorValor = pontos.fold<int>(
      0,
      (maior, p) => math.max(maior, math.max(p.analises, p.totalDerivas)),
    );
    final maxY = math.max(4, maiorValor).toDouble() * 1.15;
    final passoRotulo = math.max(1, (pontos.length / 5).ceil());

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
            'Análises e divergências por dia',
            style: AppTypography.cardTitle(context),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final periodo in periodosDisponiveis)
                ChoiceChip(
                  key: Key('periodo-$periodo'),
                  label: Text('$periodo dias'),
                  selected: periodo == dias,
                  onSelected: (_) => aoEscolherPeriodo(periodo),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _Legenda(cor: _corAnalises, texto: 'Análises'),
              SizedBox(width: 16),
              _Legenda(cor: _corDerivas, texto: 'Divergências'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: math.max(1, pontos.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
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
                      getTitlesWidget: (value, meta) {
                        if (value != value.roundToDouble()) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.caption(context),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final indice = value.round();
                        final ehUltimo = indice == pontos.length - 1;
                        if (indice < 0 ||
                            indice >= pontos.length ||
                            (indice % passoRotulo != 0 && !ehUltimo)) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _rotuloDia(pontos[indice].dia),
                            style: AppTypography.caption(context),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  _linha(
                    pontos,
                    (p) => p.analises,
                    _corAnalises,
                    colors.primaryTint,
                  ),
                  _linha(pontos, (p) => p.totalDerivas, _corDerivas, null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _linha(
    List<PontoDiario> pontos,
    int Function(PontoDiario) valor,
    Color cor,
    Color? area,
  ) {
    return LineChartBarData(
      spots: [
        for (var i = 0; i < pontos.length; i++)
          FlSpot(i.toDouble(), valor(pontos[i]).toDouble()),
      ],
      isCurved: true,
      preventCurveOverShooting: true,
      color: cor,
      barWidth: 3,
      dotData: FlDotData(show: pontos.length <= 14),
      belowBarData: BarAreaData(show: area != null, color: area),
    );
  }
}

String _rotuloDia(DateTime dia) =>
    '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}';

class _Legenda extends StatelessWidget {
  const _Legenda({required this.cor, required this.texto});

  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(texto, style: AppTypography.caption(context)),
      ],
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
            'Divergências por tipo (total)',
            style: AppTypography.cardTitle(context),
          ),
          const SizedBox(height: 12),
          if (total == 0)
            Text(
              'Nenhuma divergência registrada ainda.',
              style: AppTypography.body(context),
            )
          else
            for (final tipo in tiposDeDesvio)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BarraDeTipo(
                  rotulo: rotuloTipoDesvio(tipo),
                  quantidade: derivasPorTipo[tipo] ?? 0,
                  proporcao: (derivasPorTipo[tipo] ?? 0) / total,
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
            backgroundColor: context.colors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
