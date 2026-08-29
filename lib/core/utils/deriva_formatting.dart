import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

const _meses = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

/// "Hoje, às 14:32" / "Ontem, às 18:10" / "12 de Agosto, 2026" — mesmo
/// padrão do card de histórico no Figma. Usado em qualquer tela que
/// precise mostrar a data de uma análise (histórico, detalhe, tendência).
String formatarDataRelativa(DateTime dataUtc) {
  final data = dataUtc.toLocal();
  final agora = DateTime.now();
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final dia = DateTime(data.year, data.month, data.day);
  final diferencaDias = hoje.difference(dia).inDays;

  final hora = data.hour.toString().padLeft(2, '0');
  final minuto = data.minute.toString().padLeft(2, '0');

  if (diferencaDias == 0) return 'Hoje, às $hora:$minuto';
  if (diferencaDias == 1) return 'Ontem, às $hora:$minuto';

  final mes = _meses[data.month - 1];
  final mesCapitalizado = mes[0].toUpperCase() + mes.substring(1);
  return '${data.day} de $mesCapitalizado, ${data.year}';
}

/// Rótulo legível pro `tipoDesvio` principal de uma análise ("SENTIDO",
/// "POSICAO", "INTENSIDADE" — vem do backend). `null` quando a análise não
/// tem trechos de deriva (ou não teve o texto retido).
String rotuloTipoDesvio(String? tipoDesvio) {
  switch (tipoDesvio) {
    case 'SENTIDO':
      return 'Desvio de Sentido';
    case 'POSICAO':
      return 'Mudança de Posição';
    case 'INTENSIDADE':
      return 'Alteração de Intensidade';
    default:
      return 'Análise';
  }
}

/// Nível de severidade de uma pontuação de intensidade (0-100) — mesmos
/// limiares usados em toda cor/rótulo derivado da pontuação no Figma.
enum NivelSeveridade { alta, media, baixa }

NivelSeveridade nivelDeSeveridade(int pontuacao) {
  if (pontuacao >= 60) return NivelSeveridade.alta;
  if (pontuacao >= 30) return NivelSeveridade.media;
  return NivelSeveridade.baixa;
}

/// Cores do Score-Badge do Figma — variam com a severidade (0-100).
({Color bg, Color fg}) corDaPontuacao(int pontuacao) {
  switch (nivelDeSeveridade(pontuacao)) {
    case NivelSeveridade.alta:
      return (bg: AppColors.scoreAltoBg, fg: AppColors.scoreAltoFg);
    case NivelSeveridade.media:
      return (bg: AppColors.scoreMedioBg, fg: AppColors.scoreMedioFg);
    case NivelSeveridade.baixa:
      return (bg: AppColors.scoreBaixoBg, fg: AppColors.scoreBaixoFg);
  }
}

/// Trecho de maior intensidade de uma análise — mesma regra que o backend
/// usa pra calcular `pontuacaoIntensidade`/`tipoDesvioPrincipal` no
/// histórico, aplicada aqui sobre os trechos já carregados no app (sem
/// precisar de outra chamada). `null` quando não há trechos.
({int pontuacao, String tipoDesvio})? trechoPrincipal(
  Iterable<({String tipoDesvio, double intensidade})> trechos,
) {
  if (trechos.isEmpty) return null;
  final maisIntenso = trechos.reduce(
    (a, b) => b.intensidade > a.intensidade ? b : a,
  );
  return (
    pontuacao: (maisIntenso.intensidade * 100).round(),
    tipoDesvio: maisIntenso.tipoDesvio,
  );
}

/// Título do Score-Card (Figma: "analysis-results") — categoria da
/// divergência principal + intensidade, com concordância de gênero
/// ("Desvio de Sentido Elevado" vs. "Mudança de Posição Elevada").
String tituloBriefing(String tipoDesvio, int pontuacao) {
  final feminino = tipoDesvio == 'POSICAO' || tipoDesvio == 'INTENSIDADE';
  final severidade = switch (nivelDeSeveridade(pontuacao)) {
    NivelSeveridade.alta => feminino ? 'Elevada' : 'Elevado',
    NivelSeveridade.media => feminino ? 'Moderada' : 'Moderado',
    NivelSeveridade.baixa => 'Leve',
  };
  return '${rotuloTipoDesvio(tipoDesvio)} $severidade';
}

/// Descrição curta do Score-Card, categórica por tipo de desvio — o
/// backend não fornece um resumo textual específico por análise.
String descricaoBriefing(String tipoDesvio) {
  switch (tipoDesvio) {
    case 'SENTIDO':
      return 'A IA modificou conceitos essenciais do texto original.';
    case 'POSICAO':
      return 'A IA alterou a ordem ou a ênfase das informações originais.';
    case 'INTENSIDADE':
      return 'A IA suavizou ou intensificou o tom do texto original.';
    default:
      return 'A IA alterou parte do conteúdo do texto original.';
  }
}

/// Subtítulo do cabeçalho de resultado (Figma: "Detectamos 1 divergência
/// crítica"), com concordância de número e a severidade da pior divergência.
String subtituloResultado(int quantidadeTrechos, int? pontuacaoMaxima) {
  if (quantidadeTrechos == 0 || pontuacaoMaxima == null) {
    return 'Nenhuma divergência de sentido foi encontrada.';
  }
  final plural = quantidadeTrechos > 1;
  final substantivo = plural ? 'divergências' : 'divergência';
  final adjetivo = switch (nivelDeSeveridade(pontuacaoMaxima)) {
    NivelSeveridade.alta => plural ? 'críticas' : 'crítica',
    NivelSeveridade.media => plural ? 'moderadas' : 'moderada',
    NivelSeveridade.baixa => plural ? 'leves' : 'leve',
  };
  return 'Detectamos $quantidadeTrechos $substantivo $adjetivo';
}
