import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// Placeholder da Fase 0 — conteúdo real (busca, lista paginada, estado
/// vazio/carregando) chega na Fase 2, com fidelidade ao Figma
/// ("home-history").
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Histórico', style: AppTypography.titleLarge)),
    );
  }
}
