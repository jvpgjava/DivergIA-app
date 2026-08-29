import 'trecho_deriva.dart';

/// Espelha `ResultadoAnaliseResponse` do backend (`GET /api/historico/{id}`).
class ResultadoAnalise {
  const ResultadoAnalise({
    required this.analiseId,
    required this.criadoEm,
    required this.trechos,
  });

  factory ResultadoAnalise.fromJson(Map<String, dynamic> json) => ResultadoAnalise(
    analiseId: json['analiseId'] as String,
    criadoEm: DateTime.parse(json['criadoEm'] as String),
    trechos: (json['trechos'] as List<dynamic>)
        .map((e) => TrechoDeriva.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final String analiseId;
  final DateTime criadoEm;
  final List<TrechoDeriva> trechos;
}
