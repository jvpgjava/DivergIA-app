import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_color_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/deriva_formatting.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/screen_back_header.dart';
import '../../history/data/historico_api.dart';
import '../data/models/resultado_analise.dart';
import '../data/models/trecho_deriva.dart';
import 'widgets/score_card.dart';
import 'widgets/trecho_result_card.dart';

/// Tela "Resultado da análise" — fidelidade ao frame "analysis-results" do
/// Figma. Usada tanto pelo histórico (`/historico/:id`) quanto logo após
/// uma nova análise ser criada, já que o backend sempre persiste a análise
/// com um id real independente de `manterHistorico`.
class AnalysisResultScreen extends ConsumerStatefulWidget {
  const AnalysisResultScreen({super.key, required this.analiseId});

  final String analiseId;

  @override
  ConsumerState<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen> {
  late Future<ResultadoAnalise> _futuro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    // `Future(...)` garante que até uma falha síncrona na chamada vire um
    // erro da Future (e caia no `FutureBuilder`), em vez de derrubar o
    // build do widget.
    _futuro = Future(
      () => ref.read(historicoApiProvider).buscar(widget.analiseId),
    );
  }

  Future<void> _abrirSugestaoDeReescrita(TrechoDeriva trecho) async {
    final aceitou = await context.push<bool>(
      '/historico/${widget.analiseId}/trechos/${trecho.id}/reescrita',
      extra: trecho,
    );
    // Recarrega pra trazer o `sugestaoAceita` recém-persistido no trecho.
    if (aceitou == true) setState(_carregar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.screenBackground,
      body: SafeArea(
        child: FutureBuilder<ResultadoAnalise>(
          future: _futuro,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              final erro = snapshot.error;
              final mensagem = erro is ApiException
                  ? erro.message
                  : 'Erro inesperado.';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mensagem,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(context),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => setState(_carregar),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final resultado = snapshot.data!;
            final principal = trechoPrincipal(
              resultado.trechos.map(
                (t) => (tipoDesvio: t.tipoDesvio, intensidade: t.intensidade),
              ),
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                const ScreenBackHeader(
                  titulo: 'Resultado da análise',
                  tituloFontSize: 20,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 44),
                  child: Text(
                    subtituloResultado(
                      resultado.trechos.length,
                      principal?.pontuacao,
                    ),
                    style: AppTypography.body(context),
                  ),
                ),
                const SizedBox(height: 16),
                if (principal != null)
                  FadeSlideIn(
                    child: ScoreCard(
                      pontuacao: principal.pontuacao,
                      tipoDesvio: principal.tipoDesvio,
                    ),
                  ),
                for (final (indice, trecho) in resultado.trechos.indexed) ...[
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    atraso: atrasoEmCascata(indice + 1),
                    child: TrechoResultCard(
                      trecho: trecho,
                      onSugerirReescrita: () => _abrirSugestaoDeReescrita(trecho),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
