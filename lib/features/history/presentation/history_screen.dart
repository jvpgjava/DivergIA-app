import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/deriva_formatting.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/fade_slide_in.dart';
import 'historico_controller.dart';
import 'widgets/history_card.dart';

const _tiposDesvio = ['SENTIDO', 'POSICAO', 'INTENSIDADE'];

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

  Future<void> _abrirFiltros() {
    return showAppBottomSheet<void>(
      context,
      builder: (context) => const _FiltrosSheet(),
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
      backgroundColor: context.colors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minhas análises',
                          style: AppTypography.titleMedium(
                            context,
                          ).copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Histórico de comparações de sentido',
                          style: AppTypography.body(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => context.push('/historico/tendencia'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        border: Border.all(color: context.colors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.trendingUp, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceInput,
                        border: Border.all(color: context.colors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.search,
                            size: 16,
                            color: context.colors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _buscaController,
                              onChanged: (valor) => ref
                                  .read(historicoControllerProvider.notifier)
                                  .buscar(valor),
                              style: AppTypography.body(
                                context,
                              ).copyWith(color: context.colors.textPrimary),
                              cursorColor: AppColors.primary,
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: 'Buscar análise...',
                              ),
                            ),
                          ),
                          if (_buscaController.text.isNotEmpty)
                            InkWell(
                              onTap: () {
                                _buscaController.clear();
                                ref
                                    .read(historicoControllerProvider.notifier)
                                    .buscar('');
                                setState(() {});
                              },
                              customBorder: const CircleBorder(),
                              child: Icon(
                                LucideIcons.x,
                                size: 16,
                                color: context.colors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _abrirFiltros,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: state.temFiltroAtivo
                            ? context.colors.primaryTint
                            : context.colors.surfaceInput,
                        border: Border.all(
                          color: state.temFiltroAtivo
                              ? AppColors.primary
                              : context.colors.border,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        LucideIcons.slidersHorizontal,
                        size: 18,
                        color: state.temFiltroAtivo
                            ? AppColors.primary
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildConteudo(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo(BuildContext context, HistoricoState state) {
    if (state.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
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
                style: AppTypography.body(context),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.read(historicoControllerProvider.notifier).carregar(),
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
            style: AppTypography.body(context),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          ref.read(historicoControllerProvider.notifier).carregar(),
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          final item = itens[index];
          return FadeSlideIn(
            atraso: atrasoEmCascata(index),
            child: HistoryCard(
              analise: item,
              onTap: () => context.push('/historico/${item.id}'),
            ),
          );
        },
      ),
    );
  }
}

class _FiltrosSheet extends ConsumerWidget {
  const _FiltrosSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historicoControllerProvider);
    final notifier = ref.read(historicoControllerProvider.notifier);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filtrar análises', style: AppTypography.cardTitle(context)),
              if (state.temFiltroAtivo ||
                  state.ordenacao != OrdenacaoHistorico.recentes)
                TextButton(
                  onPressed: () {
                    notifier.filtrarPorTipo(null);
                    notifier.ordenarPor(OrdenacaoHistorico.recentes);
                  },
                  child: const Text('Limpar'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Tipo de divergência', style: AppTypography.label(context)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FiltroChip(
                rotulo: 'Todos',
                selecionado: state.filtroTipo == null,
                onTap: () => notifier.filtrarPorTipo(null),
              ),
              for (final tipo in _tiposDesvio)
                _FiltroChip(
                  rotulo: rotuloTipoDesvio(tipo),
                  selecionado: state.filtroTipo == tipo,
                  onTap: () => notifier.filtrarPorTipo(tipo),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Ordenar por', style: AppTypography.label(context)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FiltroChip(
                rotulo: 'Mais recentes',
                selecionado: state.ordenacao == OrdenacaoHistorico.recentes,
                onTap: () => notifier.ordenarPor(OrdenacaoHistorico.recentes),
              ),
              _FiltroChip(
                rotulo: 'Maior intensidade',
                selecionado:
                    state.ordenacao == OrdenacaoHistorico.maiorIntensidade,
                onTap: () =>
                    notifier.ordenarPor(OrdenacaoHistorico.maiorIntensidade),
              ),
              _FiltroChip(
                rotulo: 'Menor intensidade',
                selecionado:
                    state.ordenacao == OrdenacaoHistorico.menorIntensidade,
                onTap: () =>
                    notifier.ordenarPor(OrdenacaoHistorico.menorIntensidade),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${state.itensFiltrados.length} análise(s) encontrada(s)',
            style: AppTypography.caption(context).copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    required this.rotulo,
    required this.selecionado,
    required this.onTap,
  });

  final String rotulo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.primary : colors.surfaceInput,
          border: Border.all(
            color: selecionado ? AppColors.primary : colors.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          rotulo,
          style: AppTypography.caption(context).copyWith(
            color: selecionado ? Colors.white : colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
