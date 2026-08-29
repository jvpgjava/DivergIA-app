import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'models/consentimento.dart';

/// Chamadas HTTP de consentimento — espelha `ConsentimentoController` do
/// backend (`/api/consentimento`): preferências de manter histórico e
/// contribuir com o RAG.
class ConsentimentoApi {
  ConsentimentoApi(this._client);

  final ApiClient _client;

  Future<Consentimento> obter() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/consentimento',
    );
    return Consentimento.fromJson(response.data!);
  }

  Future<Consentimento> atualizar({
    required bool manterHistorico,
    required bool contribuirParaRag,
  }) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/api/consentimento',
      data: {
        'manterHistorico': manterHistorico,
        'contribuirParaRag': contribuirParaRag,
      },
    );
    return Consentimento.fromJson(response.data!);
  }
}

final consentimentoApiProvider = Provider<ConsentimentoApi>((ref) {
  return ConsentimentoApi(ref.watch(apiClientProvider));
});
