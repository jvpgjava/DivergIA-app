import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/features/history/data/historico_api.dart';
import 'package:divergia_app/features/history/data/models/painel_tendencia.dart';
import 'package:divergia_app/features/history/presentation/tendencia_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHistoricoApi extends Mock implements HistoricoApi {}

void main() {
  late _MockHistoricoApi api;

  final painel = PainelTendencia(
    totalAnalises: 3,
    totalDerivas: 4,
    intensidadeMedia: 0.4,
    derivasPorTipo: const {'SENTIDO': 4},
    evolucaoMensal: const [],
  );

  setUp(() {
    api = _MockHistoricoApi();
  });

  test('deveCarregarOPainelAutomaticamenteAoSerCriado', () async {
    when(() => api.tendencia()).thenAnswer((_) async => painel);

    final controller = TendenciaController(api);
    expect(controller.state.loading, isTrue);

    await Future<void>.delayed(Duration.zero);

    expect(controller.state.loading, isFalse);
    expect(controller.state.painel, painel);
    expect(controller.state.errorMessage, isNull);
  });

  test('deveExporMensagemDeErroQuandoAChamadaFalha', () async {
    when(() => api.tendencia()).thenThrow(const NetworkException());

    final controller = TendenciaController(api);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.loading, isFalse);
    expect(controller.state.painel, isNull);
    expect(controller.state.errorMessage, isNotNull);
  });

  test('carregarNovamenteDeveRefazerAChamada', () async {
    when(() => api.tendencia()).thenThrow(const NetworkException());
    final controller = TendenciaController(api);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.errorMessage, isNotNull);

    when(() => api.tendencia()).thenAnswer((_) async => painel);
    await controller.carregar();

    expect(controller.state.painel, painel);
    expect(controller.state.errorMessage, isNull);
  });
}
