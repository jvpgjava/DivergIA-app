/// Espelha `TrechoDerivaResponse` do backend.
class TrechoDeriva {
  const TrechoDeriva({
    required this.id,
    required this.tipoDesvio,
    required this.trechoOriginal,
    required this.trechoEditado,
    required this.explicacao,
    required this.intensidade,
  });

  factory TrechoDeriva.fromJson(Map<String, dynamic> json) => TrechoDeriva(
    id: json['id'] as String,
    tipoDesvio: json['tipoDesvio'] as String,
    trechoOriginal: json['trechoOriginal'] as String,
    trechoEditado: json['trechoEditado'] as String,
    explicacao: json['explicacao'] as String,
    intensidade: (json['intensidade'] as num).toDouble(),
  );

  final String id;
  final String tipoDesvio;
  final String trechoOriginal;
  final String trechoEditado;
  final String explicacao;
  final double intensidade;
}
