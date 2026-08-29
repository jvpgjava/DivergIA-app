import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../analysis/data/models/trecho_deriva.dart';
import 'rewrite_controller.dart';

/// Tela "Sugestão de reescrita" — fidelidade ao frame "rewrite-suggestion"
/// do Figma. O backend não tem uma ação de "aceitar"/"descartar" (a
/// sugestão nunca é persistida, só recalculada sob demanda), então essas
/// duas ações só fecham a tela — "aceitar" é o usuário confirmando que já
/// leu/copiou o texto (editável) que preferir usar por conta própria.
class RewriteSuggestionScreen extends ConsumerStatefulWidget {
  const RewriteSuggestionScreen({super.key, required this.trecho});

  final TrechoDeriva trecho;

  @override
  ConsumerState<RewriteSuggestionScreen> createState() =>
      _RewriteSuggestionScreenState();
}

class _RewriteSuggestionScreenState
    extends ConsumerState<RewriteSuggestionScreen> {
  final _sugestaoController = TextEditingController();
  bool _textoInicializado = false;

  @override
  void dispose() {
    _sugestaoController.dispose();
    super.dispose();
  }

  void _aceitar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sugestão aceita.')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rewriteControllerProvider(widget.trecho.id));

    if (!_textoInicializado && state.sugestao != null) {
      _sugestaoController.text = state.sugestao!;
      _textoInicializado = true;
    }

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.chevronLeft),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 4),
                Text(
                  'Sugestão de reescrita',
                  style: AppTypography.titleMedium.copyWith(fontSize: 22),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'Fidelidade e polidez combinadas',
                style: AppTypography.body,
              ),
            ),
            const SizedBox(height: 20),
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
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref
                          .read(
                            rewriteControllerProvider(
                              widget.trecho.id,
                            ).notifier,
                          )
                          .carregar(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            else ...[
              _ContextCard(trechoOriginal: widget.trecho.trechoOriginal),
              const SizedBox(height: 20),
              Text('Alternativa recomendada', style: AppTypography.cardTitle),
              const SizedBox(height: 12),
              // `Border` não suporta `borderRadius` com cores não uniformes
              // por lado — por isso o acento azul à esquerda é uma faixa
              // separada dentro de um `Row`, em vez de um `Border.left`.
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(width: 4, child: ColoredBox(color: AppColors.primary)),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _sugestaoController,
                            maxLines: null,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _InsightBox(explicacao: widget.trecho.explicacao),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: Text('Descartar', style: AppTypography.label),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _aceitar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        'Aceitar sugestão',
                        style: AppTypography.buttonText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Esta é uma estimativa heurística apoiada em IA.',
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.trechoOriginal});

  final String trechoOriginal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRECHO ORIGINAL ALTERADO',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$trechoOriginal"',
            style: AppTypography.bodyEmphasis.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightBox extends StatelessWidget {
  const _InsightBox({required this.explicacao});

  final String explicacao;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Por que esta alternativa?',
            style: AppTypography.cardTitle.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            explicacao,
            style: AppTypography.body.copyWith(color: AppColors.textLabel),
          ),
        ],
      ),
    );
  }
}
