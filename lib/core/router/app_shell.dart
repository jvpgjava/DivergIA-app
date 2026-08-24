import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_bottom_nav.dart';

/// Casca com a bottom nav (Figma: "Bottom-Nav"), compartilhada pelas telas
/// de Histórico e Perfil. O botão central sempre empurra "Nova análise" —
/// não é uma aba, é uma ação.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.tab, required this.child});

  final AppNavTab tab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        selected: tab,
        onHistoricoTap: () => context.go('/historico'),
        onNovaAnaliseTap: () => context.push('/nova-analise'),
        onPerfilTap: () => context.go('/perfil'),
      ),
    );
  }
}
