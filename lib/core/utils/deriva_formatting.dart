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

/// Cores do Score-Badge do Figma — variam com a severidade (0-100).
({Color bg, Color fg}) corDaPontuacao(int pontuacao) {
  if (pontuacao >= 60) {
    return (bg: AppColors.scoreAltoBg, fg: AppColors.scoreAltoFg);
  }
  if (pontuacao >= 30) {
    return (bg: AppColors.scoreMedioBg, fg: AppColors.scoreMedioFg);
  }
  return (bg: AppColors.scoreBaixoBg, fg: AppColors.scoreBaixoFg);
}
