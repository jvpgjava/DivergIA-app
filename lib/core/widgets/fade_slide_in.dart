import 'package:flutter/material.dart';

/// Fade + leve deslocamento vertical ao aparecer — usado em listas/telas que
/// revelam conteúdo depois de um carregamento (histórico, resultado da
/// análise, painel de tendência, perfil), com um atraso opcional por índice
/// pra dar aquele efeito "em cascata" quando usado em vários itens seguidos.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.atraso = Duration.zero});

  final Widget child;
  final Duration atraso;

  static const _duracaoEntrada = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: _duracaoEntrada + atraso,
      builder: (context, valorLinear, child) {
        // `valorLinear` cresce de forma linear pela duração TOTAL (atraso +
        // entrada) — remapeia pra só começar a animar depois do atraso, e
        // só então aplica a curva de aceleração sobre esse trecho restante.
        final tempoDecorridoMs =
            valorLinear * (_duracaoEntrada + atraso).inMilliseconds;
        final progressoLinear =
            ((tempoDecorridoMs - atraso.inMilliseconds) /
                    _duracaoEntrada.inMilliseconds)
                .clamp(0.0, 1.0);
        final progresso = Curves.easeOutCubic.transform(progressoLinear);
        return Opacity(
          opacity: progresso,
          child: Transform.translate(
            offset: Offset(0, (1 - progresso) * 14),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Atraso por índice pra usar com [FadeSlideIn] dentro de uma lista — sobe
/// 40ms por item, travando em 6 itens (240ms) pra não atrasar demais quando
/// a lista é longa.
Duration atrasoEmCascata(int indice) =>
    Duration(milliseconds: 40 * indice.clamp(0, 6));
