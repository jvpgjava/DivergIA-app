import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/features/analysis/data/analise_api.dart';
import 'package:divergia_app/features/analysis/data/models/resultado_analise.dart';
import 'package:divergia_app/features/analysis/presentation/nova_analise_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnaliseApi extends Mock implements AnaliseApi {}

void main() {
  late _MockAnaliseApi api;
  late NovaAnaliseController controller;

  setUp(() {
    api = _MockAnaliseApi();
    controller = NovaAnaliseController(api);
  });

  test('analisarComSucessoDeveDevolverOResultadoESairDoLoading', () async {
    when(
      () => api.analisar(
        textoOriginal: 'original',
        arquivoOriginal: null,
        textoEditado: 'editado',
        arquivoEditado: null,
        manterHistorico: true,
      ),
    ).thenAnswer(
      (_) async => ResultadoAnalise(
        analiseId: 'abc-123',
        criadoEm: DateTime.now(),
        trechos: const [],
      ),
    );

    final resultado = await controller.analisar(
      textoOriginal: 'original',
      textoEditado: 'editado',
    );

    expect(resultado?.analiseId, 'abc-123');
    expect(controller.state.loading, isFalse);
    expect(controller.state.errorMessage, isNull);
  });

  test('analisarComFalhaDeveExporMensagemDeErroEDevolverNulo', () async {
    when(
      () => api.analisar(
        textoOriginal: 'original',
        arquivoOriginal: null,
        textoEditado: 'editado',
        arquivoEditado: null,
        manterHistorico: true,
      ),
    ).thenThrow(const NetworkException());

    final resultado = await controller.analisar(
      textoOriginal: 'original',
      textoEditado: 'editado',
    );

    expect(resultado, isNull);
    expect(controller.state.loading, isFalse);
    expect(controller.state.errorMessage, isNotNull);
  });
}
