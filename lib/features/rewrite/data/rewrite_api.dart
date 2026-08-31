import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Chamadas HTTP da sugestão de reescrita — espelham `AnaliseController` do
/// backend (`POST`/`PUT /api/analises/trechos/{trechoId}/sugestao-reescrita`).
class RewriteApi {
  RewriteApi(this._client);

  final ApiClient _client;

  /// Gera 3 alternativas de reescrita novas — cada chamada é uma nova
  /// rodada (usado tanto na primeira carga quanto em "gerar mais opções").
  Future<List<String>> sugerir(String trechoId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/analises/trechos/$trechoId/sugestao-reescrita',
    );
    return (response.data!['sugestoes'] as List).cast<String>();
  }

  /// Persiste qual das sugestões geradas o usuário escolheu aceitar —
  /// depois fica visível no resultado da análise.
  Future<void> aceitar(String trechoId, String texto) {
    return _client.put<void>(
      '/api/analises/trechos/$trechoId/sugestao-reescrita',
      data: {'texto': texto},
    );
  }
}

final rewriteApiProvider = Provider<RewriteApi>((ref) {
  return RewriteApi(ref.watch(apiClientProvider));
});
