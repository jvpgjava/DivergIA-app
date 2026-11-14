import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import 'app_back_button.dart';

class ScreenBackHeader extends StatelessWidget {
  const ScreenBackHeader({
    super.key,
    required this.titulo,
    this.tituloFontSize = 22,
  });

  final String titulo;
  final double tituloFontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppBackButton(),
        const SizedBox(width: 12),
        Text(
          titulo,
          style: AppTypography.titleMedium(
            context,
          ).copyWith(fontSize: tituloFontSize),
        ),
      ],
    );
  }
}
