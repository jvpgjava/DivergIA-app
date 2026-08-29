import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Tela de carregamento da análise — Figma: "analysis-loading". O backend
/// não expõe progresso real (é uma chamada HTTP única), então o percentual
/// e os passos aqui são só uma simulação visual enquanto a resposta não
/// chega — não representam etapas reais do processamento.
class AnalysisLoadingView extends StatefulWidget {
  const AnalysisLoadingView({super.key});

  @override
  State<AnalysisLoadingView> createState() => _AnalysisLoadingViewState();
}

class _AnalysisLoadingViewState extends State<AnalysisLoadingView> {
  Timer? _timer;
  int _percentual = 4;

  static const _passos = [
    'Comparando textos estruturalmente',
    'Consultando base de referência semântica',
    'Gerando relatório de divergências',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_percentual >= 92) return;
      setState(() => _percentual += 2);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _passoAtual {
    if (_percentual > 70) return 2;
    if (_percentual > 30) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final passoAtual = _passoAtual;
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _percentual / 100,
                    strokeWidth: 6,
                    backgroundColor: colors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colors.background,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$_percentual%',
                    style: AppTypography.displayLarge(
                      context,
                    ).copyWith(fontSize: 20, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Analisando seus textos...',
            style: AppTypography.titleMedium(context).copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Comparando sentido e identificando divergências',
            style: AppTypography.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surfaceInput,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _passos.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _PassoRow(
                    texto: _passos[i],
                    estado: _estadoDoPasso(i, passoAtual),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _EstadoPasso _estadoDoPasso(int indice, int passoAtual) {
    if (indice < passoAtual) return _EstadoPasso.concluido;
    if (indice == passoAtual) return _EstadoPasso.emAndamento;
    return _EstadoPasso.pendente;
  }
}

enum _EstadoPasso { concluido, emAndamento, pendente }

class _PassoRow extends StatelessWidget {
  const _PassoRow({required this.texto, required this.estado});

  final String texto;
  final _EstadoPasso estado;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Color corTexto = switch (estado) {
      _EstadoPasso.pendente => colors.textSecondary,
      _ => colors.textPrimary,
    };
    final FontWeight peso = estado == _EstadoPasso.emAndamento
        ? FontWeight.w600
        : FontWeight.w400;

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: switch (estado) {
            _EstadoPasso.concluido => Container(
              decoration: BoxDecoration(
                color: colors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.check,
                size: 12,
                color: AppColors.primary,
              ),
            ),
            _EstadoPasso.emAndamento => const Padding(
              padding: EdgeInsets.all(6),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            _EstadoPasso.pendente => Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.border,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: AppTypography.body(
              context,
            ).copyWith(fontSize: 14, color: corTexto, fontWeight: peso),
          ),
        ),
      ],
    );
  }
}
