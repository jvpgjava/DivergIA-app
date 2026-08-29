import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'session_controller.dart';

/// Só a marca + loading enquanto [SessionController] verifica se há uma
/// sessão válida salva — quem decide pra onde ir depois é o `redirect` do
/// go_router (ver `app_router.dart`), reagindo à mudança de
/// [SessionStatus].
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sessionControllerProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('DivergIA', style: AppTypography.displayLarge(context)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
