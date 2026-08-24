import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// Placeholder da Fase 0 — conteúdo real chega na Fase 3, com fidelidade
/// ao Figma ("new-analysis-input").
class NewAnalysisScreen extends StatelessWidget {
  const NewAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('Nova análise', style: AppTypography.titleLarge),
      ),
    );
  }
}
