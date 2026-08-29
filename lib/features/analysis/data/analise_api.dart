import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'models/arquivo_selecionado.dart';
import 'models/resultado_analise.dart';

/// Chamadas HTTP de análise — espelha `AnaliseController` do backend
/// (`POST /api/analises`, multipart). Cada lado (original/editado) é
/// texto colado OU arquivo, nunca os dois — a mesma regra do
/// `EntradaTexto` do backend.
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
    );
    return ResultadoAnalise.fromJson(response.data!);
  }
}

final analiseApiProvider = Provider<AnaliseApi>((ref) {
  return AnaliseApi(ref.watch(apiClientProvider));
});
