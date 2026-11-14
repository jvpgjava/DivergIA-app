import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_bottom_nav.dart';

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
