import 'trecho_deriva.dart';

class ResultadoAnalise {
  const ResultadoAnalise({
    required this.analiseId,
    required this.criadoEm,
    required this.trechos,
    this.textoOriginal,
    this.textoEditado,
  });

  factory ResultadoAnalise.fromJson(Map<String, dynamic> json) =>
      ResultadoAnalise(
        analiseId: json['analiseId'] as String,
        criadoEm: DateTime.parse(json['criadoEm'] as String),
        textoOriginal: json['textoOriginal'] as String?,
        textoEditado: json['textoEditado'] as String?,
        trechos: (json['trechos'] as List<dynamic>)
            .map((e) => TrechoDeriva.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String analiseId;
  final DateTime criadoEm;
  final List<TrechoDeriva> trechos;

  final String? textoOriginal;
  final String? textoEditado;
}
