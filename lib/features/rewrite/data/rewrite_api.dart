import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Chamada HTTP da sugestão de reescrita — espelha `AnaliseController` do
/// backend (`POST /api/analises/trechos/{trechoId}/sugestao-reescrita`).
class RewriteApi {
  RewriteApi(this._client);

  final ApiClient _client;

  Future<String> sugerir(String trechoId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/analises/trechos/$trechoId/sugestao-reescrita',
    );
    return response.data!['sugestao'] as String;
  }
}

final rewriteApiProvider = Provider<RewriteApi>((ref) {
  return RewriteApi(ref.watch(apiClientProvider));
});
