import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
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
    final color = active ? AppColors.textPrimary : AppColors.textSecondary;
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
            Text(label, style: AppTypography.navLabel.copyWith(color: color)),
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
        decoration: const BoxDecoration(
          color: AppColors.textPrimary,
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.plus, size: 24, color: Colors.white),
      ),
    );
  }
}
