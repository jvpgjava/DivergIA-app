import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/historico_api.dart';
import '../data/models/painel_tendencia.dart';

class TendenciaState {
  const TendenciaState({this.loading = true, this.errorMessage, this.painel});

  final bool loading;
  final String? errorMessage;
  final PainelTendencia? painel;
}

/// Busca o painel de tendência assim que criado — a tela não tem outro
/// gatilho, ela já abre carregando.
class TendenciaController extends StateNotifier<TendenciaState> {
  TendenciaController(this._api) : super(const TendenciaState()) {
    carregar();
  }

  final HistoricoApi _api;

  Future<void> carregar() async {
    state = const TendenciaState(loading: true);
    try {
      final painel = await _api.tendencia();
      state = TendenciaState(loading: false, painel: painel);
    } on ApiException catch (e) {
      state = TendenciaState(loading: false, errorMessage: e.message);
    }
  }
}

final tendenciaControllerProvider = StateNotifierProvider.autoDispose<
  TendenciaController,
  TendenciaState
>((ref) {
  return TendenciaController(ref.watch(historicoApiProvider));
});
