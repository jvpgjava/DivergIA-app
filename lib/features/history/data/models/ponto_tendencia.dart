/// Espelha `PontoTendenciaResponse` do backend — um mês agregado do painel
/// de tendência (`GET /api/historico/tendencia`).
class PontoTendencia {
  const PontoTendencia({
    required this.mes,
    required this.quantidadeAnalises,
    required this.quantidadeDerivas,
    required this.intensidadeMedia,
  });

  factory PontoTendencia.fromJson(Map<String, dynamic> json) => PontoTendencia(
    mes: json['mes'] as String,
    quantidadeAnalises: json['quantidadeAnalises'] as int,
    quantidadeDerivas: json['quantidadeDerivas'] as int,
    intensidadeMedia: (json['intensidadeMedia'] as num).toDouble(),
  );

  /// Formato `yyyy-MM` (`YearMonth.toString()` do backend).
  final String mes;
  final int quantidadeAnalises;
  final int quantidadeDerivas;
  final double intensidadeMedia;
}
