import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import 'models/arquivo_selecionado.dart';
import 'models/resultado_analise.dart';

class AnaliseApi {
  AnaliseApi(this._client);

  final ApiClient _client;

  Future<ResultadoAnalise> analisar({
    String? textoOriginal,
    ArquivoSelecionado? arquivoOriginal,
    String? textoEditado,
    ArquivoSelecionado? arquivoEditado,
    required bool manterHistorico,
  }) async {
    final formData = FormData.fromMap({
      'textoOriginal': ?textoOriginal,
      if (arquivoOriginal != null)
        'arquivoOriginal': MultipartFile.fromBytes(
          arquivoOriginal.bytes,
          filename: arquivoOriginal.nome,
        ),
      'textoEditado': ?textoEditado,
      if (arquivoEditado != null)
        'arquivoEditado': MultipartFile.fromBytes(
          arquivoEditado.bytes,
          filename: arquivoEditado.nome,
        ),
      'manterHistorico': manterHistorico.toString(),
    });

    final response = await _client.post<Map<String, dynamic>>(
      '/api/analises',
      data: formData,
      receiveTimeout: ApiConfig.iaTimeout,
    );
    return ResultadoAnalise.fromJson(response.data!);
  }
}

final analiseApiProvider = Provider<AnaliseApi>((ref) {
  return AnaliseApi(ref.watch(apiClientProvider));
});
