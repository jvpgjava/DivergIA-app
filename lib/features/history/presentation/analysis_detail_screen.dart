import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/deriva_formatting.dart';
import '../data/historico_api.dart';
import '../data/models/resultado_analise.dart';

/// Placeholder da Fase 2 — já busca e mostra o dado real da análise, mas
/// sem a fidelidade visual ao Figma ("analysis-results"), que é escopo da
/// Fase 4.
class AnalysisDetailScreen extends ConsumerStatefulWidget {
  const AnalysisDetailScreen({super.key, required this.analiseId});

  final String analiseId;

  @override
  ConsumerState<AnalysisDetailScreen> createState() => _AnalysisDetailScreenState();
}

class _AnalysisDetailScreenState extends ConsumerState<AnalysisDetailScreen> {
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
    _futuro = Future(() => ref.read(historicoApiProvider).buscar(widget.analiseId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Detalhe da análise'),
      ),
      body: FutureBuilder<ResultadoAnalise>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            final erro = snapshot.error;
            final mensagem = erro is ApiException ? erro.message : 'Erro inesperado.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(mensagem, textAlign: TextAlign.center, style: AppTypography.body),
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
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(formatarDataRelativa(resultado.criadoEm), style: AppTypography.body),
              const SizedBox(height: 16),
              if (resultado.trechos.isEmpty)
                Text('Nenhum desvio de sentido encontrado.', style: AppTypography.bodyEmphasis),
              for (final trecho in resultado.trechos) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${rotuloTipoDesvio(trecho.tipoDesvio)} · ${(trecho.intensidade * 100).round()} pts',
                        style: AppTypography.cardTitle,
                      ),
                      const SizedBox(height: 8),
                      Text('Original: ${trecho.trechoOriginal}', style: AppTypography.body),
                      const SizedBox(height: 4),
                      Text('Editado: ${trecho.trechoEditado}', style: AppTypography.body),
                      const SizedBox(height: 8),
                      Text(trecho.explicacao, style: AppTypography.bodyEmphasis),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
