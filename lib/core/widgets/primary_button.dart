import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Botão principal em pílula com gradiente (Figma: "Primary-Button"),
/// usado em login, cadastro e ações de destaque nas próximas fases.
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

    return Opacity(
      opacity: disabled && !loading ? 0.6 : 1,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          height: 52,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.primaryButtonGradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryShadow,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
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
    );
  }
}
