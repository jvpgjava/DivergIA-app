class AnaliseResumo {
  const AnaliseResumo({
    required this.id,
    required this.criadoEm,
    required this.textoRetido,
    required this.pontuacaoIntensidade,
    required this.tipoDesvioPrincipal,
    required this.textoPreview,
  });

  factory AnaliseResumo.fromJson(Map<String, dynamic> json) => AnaliseResumo(
    id: json['id'] as String,
    criadoEm: DateTime.parse(json['criadoEm'] as String),
    textoRetido: json['textoRetido'] as bool,
    pontuacaoIntensidade: json['pontuacaoIntensidade'] as int?,
    tipoDesvioPrincipal: json['tipoDesvioPrincipal'] as String?,
    textoPreview: json['textoPreview'] as String?,
  );

  final String id;
  final DateTime criadoEm;
  final bool textoRetido;
  final int? pontuacaoIntensidade;
  final String? tipoDesvioPrincipal;
  final String? textoPreview;
}
