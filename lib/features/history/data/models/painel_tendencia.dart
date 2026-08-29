import 'ponto_tendencia.dart';

/// Espelha `PainelTendenciaResponse` do backend
/// (`GET /api/historico/tendencia`).
class PainelTendencia {
  const PainelTendencia({
    required this.totalAnalises,
    required this.totalDerivas,
    required this.intensidadeMedia,
    required this.derivasPorTipo,
    required this.evolucaoMensal,
  });

  factory PainelTendencia.fromJson(Map<String, dynamic> json) =>
      PainelTendencia(
        totalAnalises: json['totalAnalises'] as int,
        totalDerivas: json['totalDerivas'] as int,
        intensidadeMedia: (json['intensidadeMedia'] as num).toDouble(),
        derivasPorTipo: (json['derivasPorTipo'] as Map<String, dynamic>).map(
          (tipo, quantidade) => MapEntry(tipo, quantidade as int),
        ),
        evolucaoMensal: (json['evolucaoMensal'] as List<dynamic>)
            .map((e) => PontoTendencia.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final int totalAnalises;
  final int totalDerivas;
  final double intensidadeMedia;

  /// Chave é o nome do `TipoDesvio` ("SENTIDO", "POSICAO", "INTENSIDADE").
  final Map<String, int> derivasPorTipo;
  final List<PontoTendencia> evolucaoMensal;
}
