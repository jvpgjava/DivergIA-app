/// Espelha `ConsentimentoResponse` do backend (`GET/PUT /api/consentimento`).
class Consentimento {
  const Consentimento({
    required this.manterHistorico,
    required this.contribuirParaRag,
    required this.concedidoEm,
  });

  factory Consentimento.fromJson(Map<String, dynamic> json) => Consentimento(
    manterHistorico: json['manterHistorico'] as bool,
    contribuirParaRag: json['contribuirParaRag'] as bool,
    concedidoEm: DateTime.parse(json['concedidoEm'] as String),
  );

  final bool manterHistorico;
  final bool contribuirParaRag;
  final DateTime concedidoEm;
}
