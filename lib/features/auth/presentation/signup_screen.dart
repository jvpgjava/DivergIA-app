import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// Placeholder da Fase 0 — conteúdo real chega na Fase 1, com fidelidade
/// ao Figma ("signup").
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Criar conta', style: AppTypography.titleLarge)),
    );
  }
}
