import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/historico_api.dart';
import '../data/models/painel_tendencia.dart';
import 'historico_eventos.dart';

class TendenciaState {
  const TendenciaState({this.loading = true, this.errorMessage, this.painel});

  final bool loading;
  final String? errorMessage;
  final PainelTendencia? painel;
}

class TendenciaController extends StateNotifier<TendenciaState> {
  TendenciaController(this._api) : super(const TendenciaState()) {
    carregar();
  }

  final HistoricoApi _api;

  Future<void> carregar({bool silencioso = false}) async {
    if (!silencioso) state = const TendenciaState(loading: true);
    try {
      final painel = await _api.tendencia();
      if (!mounted) return;
      state = TendenciaState(loading: false, painel: painel);
    } on ApiException catch (e) {
      if (!mounted || silencioso) return;
      state = TendenciaState(loading: false, errorMessage: e.message);
    }
  }
}

final tendenciaControllerProvider =
    StateNotifierProvider.autoDispose<TendenciaController, TendenciaState>((
      ref,
    ) {
      final controller = TendenciaController(ref.watch(historicoApiProvider));
      ref.listen<int>(
        historicoAlteradoProvider,
        (_, _) => controller.carregar(silencioso: true),
      );
      return controller;
    });
