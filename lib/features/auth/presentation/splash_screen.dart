import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../core/theme/app_colors.dart';
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
    final colors = context.colors;
    final modoEscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.15),
                  radius: 0.85,
                  colors: [colors.primaryTint, colors.background],
                  stops: const [0, 0.85],
                ),
              ),
            ),
          ),
          Center(
            child: Image.asset(
              modoEscuro
                  ? 'assets/icon/divergia-icon-dark.png'
                  : 'assets/icon/divergia-icon-light.png',
              key: const Key('splash-logo'),
              width: 228,
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: Center(child: _DotsCarregando()),
          ),
        ],
      ),
    );
  }
}

class _DotsCarregando extends StatelessWidget {
  const _DotsCarregando();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _Ponto(cor: AppColors.primary),
        SizedBox(width: 6),
        _Ponto(cor: Color(0x8026C6FF)),
        SizedBox(width: 6),
        _Ponto(cor: AppColors.primaryShadow),
      ],
    );
  }
}

class _Ponto extends StatelessWidget {
  const _Ponto({required this.cor});

  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
    );
  }
}
