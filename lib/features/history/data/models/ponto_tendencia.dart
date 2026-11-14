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

  final String mes;
  final int quantidadeAnalises;
  final int quantidadeDerivas;
  final double intensidadeMedia;
}
