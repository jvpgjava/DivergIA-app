import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_color_tokens.dart';
import '../theme/app_typography.dart';

enum AppNavTab { historico, perfil }

/// Barra de navegação inferior (Figma: frame "Bottom-Nav"). O botão central
/// não é uma aba selecionável — é uma ação que sempre abre "Nova análise",
/// por isso não participa do [selected].
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selected,
    required this.onHistoricoTap,
    required this.onNovaAnaliseTap,
    required this.onPerfilTap,
  });

  final AppNavTab selected;
  final VoidCallback onHistoricoTap;
  final VoidCallback onNovaAnaliseTap;
  final VoidCallback onPerfilTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 32),
              _NavTab(
                icon: LucideIcons.home,
                label: 'Histórico',
                active: selected == AppNavTab.historico,
                onTap: onHistoricoTap,
              ),
              _AddButton(onTap: onNovaAnaliseTap),
              _NavTab(
                icon: LucideIcons.user,
                label: 'Perfil',
                active: selected == AppNavTab.perfil,
                onTap: onPerfilTap,
              ),
              const SizedBox(width: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = active ? colors.textPrimary : colors.textSecondary;
    return InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.navLabel(context).copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.colors.highContrastSurface,
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.plus, size: 24, color: Colors.white),
      ),
    );
  }
}
