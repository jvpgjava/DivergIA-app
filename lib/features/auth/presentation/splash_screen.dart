import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../core/theme/app_colors.dart';
import 'session_controller.dart';

// A logo escura tem mais margem na imagem que a clara: larguras diferentes deixam as duas
// com o mesmo tamanho aparente na tela.
const _logoClara = 'assets/icon/divergia-icon-light.png';
const _logoEscura = 'assets/icon/divergia-icon-dark.png';
const _larguraLogoClara = 228.0;
const _larguraLogoEscura = 238.0;

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sessionControllerProvider);
    final modoEscuro = Theme.of(context).brightness == Brightness.dark;

    // Fundo liso e igual ao da splash do sistema (branco no tema claro): a troca entre as duas
    // não pode ter degrau de cor, para a abertura parecer uma tela só.
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (context, opacidade, filho) =>
                  Opacity(opacity: opacidade, child: filho),
              child: Image.asset(
                modoEscuro ? _logoEscura : _logoClara,
                key: const Key('splash-logo'),
                width: modoEscuro ? _larguraLogoEscura : _larguraLogoClara,
              ),
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
