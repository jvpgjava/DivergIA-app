import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_color_tokens.dart';
import '../theme/app_typography.dart';

/// Cabeçalho padrão de "botão de voltar + título" — mesmo InkWell 32x32
/// justado à esquerda usado em signup/esqueci-senha/nova-análise/termos.
/// Existia inconsistência: algumas telas usavam um `IconButton` cru, que
/// tem uma área de toque bem maior que o ícone visível e por isso "empurra"
/// o ícone pra longe da borda esquerda, desalinhado com o resto do app.
class ScreenBackHeader extends StatelessWidget {
  const ScreenBackHeader({
    super.key,
    required this.titulo,
    this.tituloFontSize = 22,
  });

  final String titulo;
  final double tituloFontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.pop(),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.colors.surfaceInput,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.chevronLeft, size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          titulo,
          style: AppTypography.titleMedium(
            context,
          ).copyWith(fontSize: tituloFontSize),
        ),
      ],
    );
  }
}
