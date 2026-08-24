import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';

/// Placeholder da Fase 0 — conteúdo real chega na Fase 6, com fidelidade
/// ao Figma ("profile-settings").
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Perfil', style: AppTypography.titleLarge)),
    );
  }
}
