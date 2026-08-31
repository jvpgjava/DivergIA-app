import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/arquivo_selecionado.dart';

const _limiteCaracteres = 10000;

/// Campo "Texto original"/"Texto editado" — Figma: "Original-Block"/
/// "Edited-Block". Aceita texto colado OU um arquivo (nunca os dois);
/// quando um arquivo é escolhido, a caixa de texto vira um card com o
/// nome do arquivo (não tem referência no Figma pra esse estado — segue a
/// mesma linguagem visual das outras caixas).
///
/// Rótulo e contador ficam FORA da caixa, e "Anexar arquivo" também — a
/// caixa em si só existe pra digitar o texto (ou mostrar o arquivo
/// escolhido); antes havia um ícone de clipe flutuando por cima do texto
/// digitado, o que criava a impressão de "duas caixas" na mesma área.
class AnaliseInputField extends StatefulWidget {
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
  State<AnaliseInputField> createState() => _AnaliseInputFieldState();
}

class _AnaliseInputFieldState extends State<AnaliseInputField> {
  final _focusNode = FocusNode();
  bool _focado = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _focado = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final comErro = widget.errorText != null;
    final corBorda = comErro
        ? AppColors.danger
        : _focado
        ? AppColors.primary
        : colors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppTypography.cardTitle(context).copyWith(fontSize: 14),
            ),
            if (widget.arquivo == null)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.controller,
                builder: (context, value, _) {
                  final quantidade = value.text.length;
                  final proximoDoLimite = quantidade >= _limiteCaracteres * 0.9;
                  return Text(
                    '$quantidade / $_limiteCaracteres caract.',
                    style: AppTypography.caption(context).copyWith(
                      fontSize: 11,
                      color: proximoDoLimite
                          ? AppColors.danger
                          : colors.textSecondary,
                    ),
                  );
                },
              )
            else
              InkWell(
                onTap: widget.onRemoverArquivo,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.x, size: 12, color: AppColors.danger),
                    const SizedBox(width: 2),
                    Text(
                      'Remover arquivo',
                      style: AppTypography.caption(
                        context,
                      ).copyWith(color: AppColors.danger, fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: widget.arquivo != null ? null : 140,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceInput,
            border: Border.all(color: corBorda, width: _focado ? 1.5 : 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: widget.arquivo != null
              ? _ArquivoCard(arquivo: widget.arquivo!)
              : TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  maxLength: _limiteCaracteres,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                  cursorColor: AppColors.primary,
                  style: AppTypography.body(
                    context,
                  ).copyWith(fontSize: 13, color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTypography.body(
                      context,
                    ).copyWith(fontSize: 13),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
        ),
        if (widget.arquivo == null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: widget.onAnexar,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.paperclip,
                      size: 14,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Anexar arquivo',
                      style: AppTypography.caption(
                        context,
                      ).copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
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
    return Row(
      children: [
        const Icon(LucideIcons.fileText, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            arquivo.nome,
            style: AppTypography.bodyEmphasis(context).copyWith(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
