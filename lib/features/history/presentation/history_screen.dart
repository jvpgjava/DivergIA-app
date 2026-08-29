import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'historico_controller.dart';
import 'widgets/history_card.dart';

/// Tela "Minhas análises" — fidelidade ao frame "home-history" do Figma.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollController = ScrollController();
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_aoRolar);
  }

  void _aoRolar() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(historicoControllerProvider.notifier).carregarMais();
    }
  }

  void _avisarFiltroEmBreve() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtros avançados ainda não disponíveis.')),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historicoControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Minhas análises', style: AppTypography.titleMedium.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text('Histórico de comparações de sentido', style: AppTypography.body),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.search, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _buscaController,
                              onChanged: (valor) =>
                                  ref.read(historicoControllerProvider.notifier).buscar(valor),
                              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Buscar análise...',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _avisarFiltroEmBreve,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.slidersHorizontal, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildConteudo(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo(HistoricoState state) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.read(historicoControllerProvider.notifier).carregar(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final itens = state.itensPaginados;

    if (itens.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            state.busca.isEmpty
                ? 'Nenhuma análise ainda. Toque em "+" para começar.'
                : 'Nenhuma análise encontrada para essa busca.',
            textAlign: TextAlign.center,
            style: AppTypography.body,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(historicoControllerProvider.notifier).carregar(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: itens.length + (state.temMaisParaCarregar ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= itens.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            );
          }
          final item = itens[index];
          return HistoryCard(
            analise: item,
            onTap: () => context.push('/historico/${item.id}'),
          );
        },
      ),
    );
  }
}
