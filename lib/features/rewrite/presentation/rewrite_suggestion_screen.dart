import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/screen_back_header.dart';
import '../../analysis/data/models/trecho_deriva.dart';
import 'rewrite_controller.dart';

/// Tela "Sugestão de reescrita" — fidelidade ao frame "rewrite-suggestion"
/// do Figma, com 3 alternativas selecionáveis (o backend agora gera 3 em
/// vez de 1). "Descartar" pergunta se o usuário quer gerar mais 3 opções;
/// "Aceitar sugestão" persiste a escolhida via `PUT .../sugestao-reescrita`
/// e fecha a tela devolvendo `true`, pra a tela de resultado recarregar.
class RewriteSuggestionScreen extends ConsumerWidget {
  const RewriteSuggestionScreen({super.key, required this.trecho});

  final TrechoDeriva trecho;

  Future<void> _descartar(BuildContext context, WidgetRef ref) async {
    final gerarMais = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar sugestões'),
        content: const Text(
          'Quer que a IA gere mais 3 opções de reescrita, ou prefere sair sem aceitar nenhuma?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Sair'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Gerar mais opções'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (gerarMais == true) {
      ref.read(rewriteControllerProvider(trecho.id).notifier).carregar();
    } else {
      context.pop();
    }
  }

  Future<void> _aceitar(BuildContext context, WidgetRef ref) async {
    final sucesso = await ref
        .read(rewriteControllerProvider(trecho.id).notifier)
        .aceitar();
    if (!context.mounted) return;
    if (sucesso) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sugestão aceita.')));
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rewriteControllerProvider(trecho.id));
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.screenBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            const ScreenBackHeader(titulo: 'Sugestão de reescrita'),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Text(
                'Fidelidade e polidez combinadas',
                style: AppTypography.body(context),
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
                      style: AppTypography.body(context),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref
                          .read(rewriteControllerProvider(trecho.id).notifier)
                          .carregar(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            else ...[
              _ContextCard(trechoOriginal: trecho.trechoOriginal),
              const SizedBox(height: 20),
              Text(
                'Escolha uma alternativa',
                style: AppTypography.cardTitle(context),
              ),
              const SizedBox(height: 12),
              for (final (indice, sugestao) in state.sugestoes.indexed) ...[
                if (indice > 0) const SizedBox(height: 10),
                _SugestaoOption(
                  texto: sugestao,
                  selecionada: indice == state.indiceSelecionado,
                  onTap: () => ref
                      .read(rewriteControllerProvider(trecho.id).notifier)
                      .selecionar(indice),
                ),
              ],
              const SizedBox(height: 20),
              _InsightBox(explicacao: trecho.explicacao),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _descartar(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(color: colors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        'Descartar',
                        style: AppTypography.label(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.aceitando
                          ? null
                          : () => _aceitar(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: state.aceitando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
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
                style: AppTypography.caption(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SugestaoOption extends StatelessWidget {
  const _SugestaoOption({
    required this.texto,
    required this.selecionada,
    required this.onTap,
  });

  final String texto;
  final bool selecionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      // `Border` não suporta `borderRadius` com cores não uniformes por
      // lado — por isso o acento azul à esquerda (só quando selecionada) é
      // uma faixa separada dentro de um `Row`, em vez de um `Border.left`.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 4,
                child: ColoredBox(
                  color: selecionada ? AppColors.primary : Colors.transparent,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selecionada ? colors.primaryTint : colors.background,
                    border: Border.all(
                      color: selecionada ? AppColors.primary : colors.border,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        selecionada
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: selecionada
                            ? AppColors.primary
                            : colors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          texto,
                          style: AppTypography.body(
                            context,
                          ).copyWith(color: colors.textPrimary, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRECHO ORIGINAL ALTERADO',
            style: AppTypography.caption(
              context,
            ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            '"$trechoOriginal"',
            style: AppTypography.bodyEmphasis(
              context,
            ).copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
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
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Por que esta alternativa?',
            style: AppTypography.cardTitle(
              context,
            ).copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            explicacao,
            style: AppTypography.body(
              context,
            ).copyWith(color: colors.textLabel),
          ),
        ],
      ),
    );
  }
}
