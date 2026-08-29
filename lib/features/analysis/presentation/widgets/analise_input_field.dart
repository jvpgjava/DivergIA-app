import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/arquivo_selecionado.dart';

const _limiteCaracteres = 1000;

/// Campo "Texto original"/"Texto editado" — Figma: "Original-Block"/
/// "Edited-Block". Aceita texto colado OU um arquivo (nunca os dois);
/// quando um arquivo é escolhido, a caixa de texto vira um card com o
/// nome do arquivo (não tem referência no Figma pra esse estado — segue a
/// mesma linguagem visual das outras caixas).
class AnaliseInputField extends StatelessWidget {
  const AnaliseInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.arquivo,
    required this.onAnexar,
    required this.onRemoverArquivo,
    this.errorText,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ArquivoSelecionado? arquivo;
  final VoidCallback onAnexar;
  final VoidCallback onRemoverArquivo;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.cardTitle(context).copyWith(fontSize: 14),
            ),
            if (arquivo == null)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) => Text(
                  '${value.text.length} / $_limiteCaracteres caract.',
                  style: AppTypography.caption(
                    context,
                  ).copyWith(fontSize: 11),
                ),
              )
            else
              InkWell(
                onTap: onRemoverArquivo,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.x,
                      size: 12,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Remover arquivo',
                      style: AppTypography.caption(context).copyWith(
                        color: AppColors.danger,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (arquivo != null)
          _ArquivoCard(arquivo: arquivo!)
        else
          Container(
            height: 130,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceInput,
              border: Border.all(
                color: errorText != null ? AppColors.danger : colors.border,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: AppTypography.body(
                    context,
                  ).copyWith(fontSize: 13, color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTypography.body(
                      context,
                    ).copyWith(fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(right: 28),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: onAnexar,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        LucideIcons.paperclip,
                        size: 18,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTypography.caption(
              context,
            ).copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}

class _ArquivoCard extends StatelessWidget {
  const _ArquivoCard({required this.arquivo});

  final ArquivoSelecionado arquivo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceInput,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.fileText, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              arquivo.nome,
              style: AppTypography.bodyEmphasis(
                context,
              ).copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
