import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_color_tokens.dart';
import '../theme/app_colors.dart';

/// Checkbox no estilo do Figma ("Checkbox" da tela signup): marcado vira um
/// quadrado arredondado com borda e fundo azul-claro + ícone de check.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: value ? colors.primaryTint : Colors.transparent,
          border: Border.all(
            color: value ? AppColors.primary : colors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: value
            ? const Icon(LucideIcons.check, size: 12, color: AppColors.primary)
            : null,
      ),
    );
  }
}
