import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_color_tokens.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pop(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.colors.surfaceInput,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.chevronLeft, size: 16),
      ),
    );
  }
}
