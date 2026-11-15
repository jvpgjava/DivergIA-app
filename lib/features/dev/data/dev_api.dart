import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'models/estatisticas_globais.dart';

class DevApi {
  DevApi(this._client);

  final ApiClient _client;

  Future<EstatisticasGlobais> estatisticas({required int dias}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/dev/estatisticas',
      queryParameters: {'dias': dias},
    );
    return EstatisticasGlobais.fromJson(response.data!);
  }
}

final devApiProvider = Provider<DevApi>((ref) {
  return DevApi(ref.watch(apiClientProvider));
});
