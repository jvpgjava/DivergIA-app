const tiposDeDesvio = ['SENTIDO', 'POSICAO', 'INTENSIDADE'];

class PontoDiario {
  const PontoDiario({
    required this.dia,
    required this.analises,
    required this.derivasPorTipo,
    required this.totalDerivas,
  });

  factory PontoDiario.fromJson(Map<String, dynamic> json) => PontoDiario(
    dia: DateTime.parse(json['dia'] as String),
    analises: (json['analises'] as num).toInt(),
    derivasPorTipo: _mapaDeContagens(json['derivasPorTipo']),
    totalDerivas: (json['totalDerivas'] as num).toInt(),
  );

  final DateTime dia;
  final int analises;
  final Map<String, int> derivasPorTipo;
  final int totalDerivas;
}

class EstatisticasGlobais {
  const EstatisticasGlobais({
    required this.totalAnalises,
    required this.totalDerivas,
    required this.derivasPorTipo,
    required this.serieDiaria,
    required this.geradoEm,
  });

  factory EstatisticasGlobais.fromJson(Map<String, dynamic> json) =>
      EstatisticasGlobais(
        totalAnalises: (json['totalAnalises'] as num).toInt(),
        totalDerivas: (json['totalDerivas'] as num).toInt(),
        derivasPorTipo: _mapaDeContagens(json['derivasPorTipo']),
        serieDiaria: (json['serieDiaria'] as List<dynamic>)
            .map((e) => PontoDiario.fromJson(e as Map<String, dynamic>))
            .toList(),
        geradoEm: DateTime.parse(json['geradoEm'] as String),
      );

  final int totalAnalises;
  final int totalDerivas;
  final Map<String, int> derivasPorTipo;
  final List<PontoDiario> serieDiaria;
  final DateTime geradoEm;

  int get analisesHoje => serieDiaria.isEmpty ? 0 : serieDiaria.last.analises;
}

Map<String, int> _mapaDeContagens(Object? bruto) => {
  for (final tipo in tiposDeDesvio)
    tipo: ((bruto as Map<String, dynamic>?)?[tipo] as num?)?.toInt() ?? 0,
};
