import 'package:flutter/material.dart';

import '../theme/app_color_tokens.dart';
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

enum NivelSeveridade { alta, media, baixa }

NivelSeveridade nivelDeSeveridade(int pontuacao) {
  if (pontuacao >= 60) return NivelSeveridade.alta;
  if (pontuacao >= 30) return NivelSeveridade.media;
  return NivelSeveridade.baixa;
}

({Color bg, Color fg}) corDaPontuacao(BuildContext context, int pontuacao) {
  final colors = context.colors;
  switch (nivelDeSeveridade(pontuacao)) {
    case NivelSeveridade.alta:
      return (bg: colors.scoreAltoBg, fg: AppColors.scoreAltoFg);
    case NivelSeveridade.media:
      return (bg: colors.scoreMedioBg, fg: AppColors.scoreMedioFg);
    case NivelSeveridade.baixa:
      return (bg: colors.scoreBaixoBg, fg: AppColors.scoreBaixoFg);
  }
}

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

String tituloBriefing(String tipoDesvio, int pontuacao) {
  final feminino = tipoDesvio == 'POSICAO' || tipoDesvio == 'INTENSIDADE';
  final severidade = switch (nivelDeSeveridade(pontuacao)) {
    NivelSeveridade.alta => feminino ? 'Elevada' : 'Elevado',
    NivelSeveridade.media => feminino ? 'Moderada' : 'Moderado',
    NivelSeveridade.baixa => 'Leve',
  };
  return '${rotuloTipoDesvio(tipoDesvio)} $severidade';
}

String descricaoBriefing(String tipoDesvio) {
  switch (tipoDesvio) {
    case 'SENTIDO':
      return 'A IA modificou conceitos essenciais do texto original.';
    case 'POSICAO':
      return 'A IA inverteu ou suavizou a opinião expressa no texto original.';
    case 'INTENSIDADE':
      return 'A IA suavizou ou intensificou o tom do texto original.';
    default:
      return 'A IA alterou parte do conteúdo do texto original.';
  }
}

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
