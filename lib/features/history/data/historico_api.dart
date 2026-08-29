import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../analysis/data/models/resultado_analise.dart';
import 'models/analise_resumo.dart';

/// Chamadas HTTP do histórico — espelha `HistoricoController` do backend
/// (`/api/historico`).
class HistoricoApi {
  HistoricoApi(this._client);

  final ApiClient _client;

  Future<List<AnaliseResumo>> listar() async {
    final response = await _client.get<List<dynamic>>('/api/historico');
    return response.data!
        .map((e) => AnaliseResumo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ResultadoAnalise> buscar(String analiseId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/historico/$analiseId',
    );
    return ResultadoAnalise.fromJson(response.data!);
  }

  Future<void> excluirTudo() => _client.delete<void>('/api/historico');
}

final historicoApiProvider = Provider<HistoricoApi>((ref) {
  return HistoricoApi(ref.watch(apiClientProvider));
});
