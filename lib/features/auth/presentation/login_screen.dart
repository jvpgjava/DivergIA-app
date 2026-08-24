import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// Placeholder da Fase 0 — conteúdo real chega na Fase 1, com fidelidade
/// ao Figma ("login").
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Login', style: AppTypography.titleLarge)),
    );
  }
}
