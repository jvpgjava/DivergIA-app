import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';

class RewriteApi {
  RewriteApi(this._client);

  final ApiClient _client;

  Future<List<String>> sugerir(String trechoId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/analises/trechos/$trechoId/sugestao-reescrita',
      receiveTimeout: ApiConfig.iaTimeout,
    );
    return (response.data?['sugestoes'] as List? ?? const [])
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

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
