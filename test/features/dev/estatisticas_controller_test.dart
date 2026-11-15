import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/features/dev/data/dev_api.dart';
import 'package:divergia_app/features/dev/data/models/estatisticas_globais.dart';
import 'package:divergia_app/features/dev/presentation/estatisticas_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDevApi extends Mock implements DevApi {}

EstatisticasGlobais _estatisticas(int total) => EstatisticasGlobais(
  totalAnalises: total,
  totalDerivas: total * 2,
  derivasPorTipo: const {'SENTIDO': 1, 'POSICAO': 1, 'INTENSIDADE': 0},
  serieDiaria: [
    PontoDiario(
      dia: DateTime(2026, 11, 15),
      analises: total,
      derivasPorTipo: const {'SENTIDO': 1, 'POSICAO': 1, 'INTENSIDADE': 0},
      totalDerivas: total * 2,
    ),
  ],
  geradoEm: DateTime.utc(2026, 11, 15, 18),
);

void main() {
  late _MockDevApi api;

  setUp(() => api = _MockDevApi());

  test('carregaNaCriacaoEAtualizaSozinhoACadaIntervalo', () async {
    var total = 10;
    when(
      () => api.estatisticas(dias: any(named: 'dias')),
    ).thenAnswer((_) async => _estatisticas(total));

    final controller = EstatisticasController(
      api,
      intervalo: const Duration(milliseconds: 40),
    );
    addTearDown(controller.dispose);

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(controller.state.estatisticas?.totalAnalises, 10);

    total = 11;
    await Future<void>.delayed(const Duration(milliseconds: 90));
    expect(controller.state.estatisticas?.totalAnalises, 11);
  });

  test('pausarParaDeConsultarERetomarVoltaAConsultar', () async {
    when(
      () => api.estatisticas(dias: any(named: 'dias')),
    ).thenAnswer((_) async => _estatisticas(1));

    final controller = EstatisticasController(
      api,
      intervalo: const Duration(milliseconds: 30),
    );
    addTearDown(controller.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    controller.pausar();
    clearInteractions(api);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    verifyNever(() => api.estatisticas(dias: any(named: 'dias')));

    controller.retomar();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    verify(
      () => api.estatisticas(dias: any(named: 'dias')),
    ).called(greaterThan(0));
  });

  test('semPermissaoMostraAvisoEParaDeConsultar', () async {
    when(
      () => api.estatisticas(dias: any(named: 'dias')),
    ).thenThrow(const ForbiddenException());

    final controller = EstatisticasController(
      api,
      intervalo: const Duration(milliseconds: 30),
    );
    addTearDown(controller.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(controller.state.errorMessage, contains('não tem acesso'));
    clearInteractions(api);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    verifyNever(() => api.estatisticas(dias: any(named: 'dias')));
  });

  test('falhaDeRedeEmSegundoPlanoMantemOsNumerosJaExibidos', () async {
    var falhar = false;
    when(() => api.estatisticas(dias: any(named: 'dias'))).thenAnswer((
      _,
    ) async {
      if (falhar) throw const NetworkException();
      return _estatisticas(5);
    });

    final controller = EstatisticasController(
      api,
      intervalo: const Duration(milliseconds: 30),
    );
    addTearDown(controller.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    falhar = true;
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(controller.state.errorMessage, isNull);
    expect(controller.state.estatisticas?.totalAnalises, 5);
  });

  test('trocarOPeriodoPedeAJanelaNovaSemApagarOGrafico', () async {
    when(
      () => api.estatisticas(dias: any(named: 'dias')),
    ).thenAnswer((_) async => _estatisticas(3));

    final controller = EstatisticasController(
      api,
      intervalo: const Duration(hours: 1),
    );
    addTearDown(controller.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final pendente = controller.definirPeriodo(90);
    expect(controller.state.estatisticas, isNotNull);
    expect(controller.state.dias, 90);
    await pendente;

    verify(() => api.estatisticas(dias: 90)).called(1);
  });
}
