import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;

    // Azul claro liso, texto branco: sem gradiente, brilho nem sombra.
    return Opacity(
      opacity: disabled && !loading ? 0.6 : 1,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          child: Container(
            height: 52,
            width: double.infinity,
            alignment: Alignment.center,
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(label, style: AppTypography.buttonText),
          ),
        ),
      ),
    );
  }
}
