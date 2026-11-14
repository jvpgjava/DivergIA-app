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

  test('recusaDoServidorComCampoDeveIrParaOCampoCerto', () async {
    when(
      () => api.analisar(
        textoOriginal: 'original',
        arquivoOriginal: null,
        textoEditado: 'editado',
        arquivoEditado: null,
        manterHistorico: true,
      ),
    ).thenThrow(
      const ValidationException(
        'O texto editado tem conteúdo codificado.',
        codigo: 'CONTEUDO_CODIFICADO',
        campo: 'EDITADO',
      ),
    );

    await controller.analisar(textoOriginal: 'original', textoEditado: 'editado');

    expect(controller.state.erroEditado, 'O texto editado tem conteúdo codificado.');
    expect(controller.state.erroOriginal, isNull);
    expect(controller.state.errorMessage, isNull);
  });

  test('recusaQueValeParaOsDoisTextosDeveIrParaOErroGeral', () async {
    when(
      () => api.analisar(
        textoOriginal: 'original',
        arquivoOriginal: null,
        textoEditado: 'editado',
        arquivoEditado: null,
        manterHistorico: true,
      ),
    ).thenThrow(
      const ValidationException(
        'Os textos estão em idiomas diferentes.',
        codigo: 'IDIOMAS_DIFERENTES',
        campo: 'AMBOS',
      ),
    );

    await controller.analisar(textoOriginal: 'original', textoEditado: 'editado');

    expect(controller.state.errorMessage, 'Os textos estão em idiomas diferentes.');
    expect(controller.state.erroOriginal, isNull);
    expect(controller.state.erroEditado, isNull);
  });

  test('limparErrosDeveApagarARecusaAnterior', () async {
    when(
      () => api.analisar(
        textoOriginal: 'original',
        arquivoOriginal: null,
        textoEditado: 'editado',
        arquivoEditado: null,
        manterHistorico: true,
      ),
    ).thenThrow(
      const ValidationException('Recusado.', campo: 'ORIGINAL'),
    );
    await controller.analisar(textoOriginal: 'original', textoEditado: 'editado');
    expect(controller.state.erroOriginal, isNotNull);

    controller.limparErros();

    expect(controller.state.erroOriginal, isNull);
  });
}
