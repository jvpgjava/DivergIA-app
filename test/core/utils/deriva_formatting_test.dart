import 'package:divergia_app/core/theme/app_colors.dart';
import 'package:divergia_app/core/utils/deriva_formatting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatarDataRelativa', () {
    test('deveFormatarComoHojeQuandoEHoje', () {
      final agora = DateTime.now();
      final data = DateTime(agora.year, agora.month, agora.day, 14, 32).toUtc();

      expect(formatarDataRelativa(data), 'Hoje, às 14:32');
    });

    test('deveFormatarComoOntemQuandoEOntem', () {
      final ontem = DateTime.now().subtract(const Duration(days: 1));
      final data = DateTime(ontem.year, ontem.month, ontem.day, 18, 5).toUtc();

      expect(formatarDataRelativa(data), 'Ontem, às 18:05');
    });

    test('deveFormatarComDataCompletaQuandoForMaisAntigo', () {
      final data = DateTime.utc(2026, 8, 12, 10);

      expect(formatarDataRelativa(data), '12 de Agosto, 2026');
    });
  });

  group('rotuloTipoDesvio', () {
    test('deveTraduzirCadaTipoConhecido', () {
      expect(rotuloTipoDesvio('SENTIDO'), 'Desvio de Sentido');
      expect(rotuloTipoDesvio('POSICAO'), 'Mudança de Posição');
      expect(rotuloTipoDesvio('INTENSIDADE'), 'Alteração de Intensidade');
    });

    test('deveCairNoRotuloGenericoQuandoNulo', () {
      expect(rotuloTipoDesvio(null), 'Análise');
    });
  });

  group('corDaPontuacao', () {
    test('deveSerVermelhoParaPontuacaoAltaMaiorOuIgualA60', () {
      final cor = corDaPontuacao(72);
      expect(cor.fg, AppColors.scoreAltoFg);
    });

    test('deveSerAmareloParaPontuacaoMediaEntre30E59', () {
      final cor = corDaPontuacao(45);
      expect(cor.fg, AppColors.scoreMedioFg);
    });

    test('deveSerVerdeParaPontuacaoBaixaMenorQue30', () {
      final cor = corDaPontuacao(18);
      expect(cor.fg, AppColors.scoreBaixoFg);
    });
  });
}
