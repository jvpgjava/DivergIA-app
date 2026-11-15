import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../history/presentation/historico_eventos.dart';
import '../data/dev_api.dart';
import '../data/models/estatisticas_globais.dart';

const intervaloDeAtualizacao = Duration(seconds: 5);
const periodosDisponiveis = [7, 30, 90];

class EstatisticasState {
  const EstatisticasState({
    this.loading = true,
    this.errorMessage,
    this.estatisticas,
    this.dias = 30,
  });

  final bool loading;
  final String? errorMessage;
  final EstatisticasGlobais? estatisticas;
  final int dias;
}

class EstatisticasController extends StateNotifier<EstatisticasState> {
  EstatisticasController(this._api, {this.intervalo = intervaloDeAtualizacao})
    : super(const EstatisticasState()) {
    retomar();
    carregar();
  }

  final DevApi _api;
  final Duration intervalo;
  Timer? _timer;
  bool _semAcesso = false;

  Future<void> carregar({bool silencioso = false}) async {
    final dias = state.dias;
    if (!silencioso) {
      state = EstatisticasState(dias: dias);
    }
    try {
      final estatisticas = await _api.estatisticas(dias: dias);
      if (!mounted || dias != state.dias) return;
      state = EstatisticasState(
        loading: false,
        estatisticas: estatisticas,
        dias: dias,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      // Uma falha numa atualização em segundo plano não apaga o que já está na tela.
      if (silencioso && state.estatisticas != null) return;
      if (e is ForbiddenException) {
        _semAcesso = true;
        pausar();
        state = EstatisticasState(
          loading: false,
          dias: dias,
          errorMessage: 'Esta conta não tem acesso ao painel de desenvolvedor.',
        );
        return;
      }
      state = EstatisticasState(
        loading: false,
        dias: dias,
        errorMessage: e.message,
      );
    }
  }

  Future<void> definirPeriodo(int dias) {
    if (dias == state.dias) return Future.value();
    state = EstatisticasState(
      loading: false,
      dias: dias,
      estatisticas: state.estatisticas,
    );
    return carregar(silencioso: true);
  }

  void pausar() {
    _timer?.cancel();
    _timer = null;
  }

  void retomar() {
    // Sem permissão não adianta insistir: o servidor responderia 403 a cada ciclo.
    if (_timer != null || _semAcesso) return;
    _timer = Timer.periodic(intervalo, (_) => carregar(silencioso: true));
  }

  @override
  void dispose() {
    pausar();
    super.dispose();
  }
}

final estatisticasControllerProvider =
    StateNotifierProvider.autoDispose<
      EstatisticasController,
      EstatisticasState
    >((ref) {
      final controller = EstatisticasController(ref.watch(devApiProvider));
      // Análise feita neste aparelho aparece na hora, sem esperar o próximo ciclo.
      ref.listen<int>(
        historicoAlteradoProvider,
        (_, _) => controller.carregar(silencioso: true),
      );
      return controller;
    });
