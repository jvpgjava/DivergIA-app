import 'package:flutter/material.dart';

import '../theme/app_color_tokens.dart';
import '../theme/app_typography.dart';
import 'screen_back_header.dart';

/// Uma seção de um documento legal — um título e um ou mais parágrafos.
class SecaoLegal {
  const SecaoLegal({required this.titulo, required this.paragrafos});

  final String titulo;
  final List<String> paragrafos;
}

/// Tela genérica pra exibir um documento legal (Termos de Serviço, Política
/// de Privacidade) — mesma estrutura visual (cabeçalho com botão de voltar +
/// título) das outras telas sem referência no Figma.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.titulo,
    required this.atualizadoEm,
    required this.secoes,
  });

  final String titulo;
  final String atualizadoEm;
  final List<SecaoLegal> secoes;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.screenBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            ScreenBackHeader(titulo: titulo, tituloFontSize: 20),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Text(
                'Atualizado em $atualizadoEm',
                style: AppTypography.caption(context),
              ),
            ),
            const SizedBox(height: 24),
            for (final secao in secoes) ...[
              Text(secao.titulo, style: AppTypography.cardTitle(context)),
              const SizedBox(height: 8),
              for (final paragrafo in secao.paragrafos) ...[
                Text(
                  paragrafo,
                  style: AppTypography.body(context).copyWith(height: 1.6),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
