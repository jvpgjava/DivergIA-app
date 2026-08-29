import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/features/rewrite/data/rewrite_api.dart';
import 'package:divergia_app/features/rewrite/presentation/rewrite_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRewriteApi extends Mock implements RewriteApi {}

void main() {
  late _MockRewriteApi api;

  setUp(() {
    api = _MockRewriteApi();
  });

  test('deveCarregarASugestaoAutomaticamenteAoSerCriado', () async {
    when(() => api.sugerir('trecho-1')).thenAnswer((_) async => 'sugestão');

    final controller = RewriteController(api, 'trecho-1');
    expect(controller.state.loading, isTrue);

    await Future<void>.delayed(Duration.zero);

    expect(controller.state.loading, isFalse);
    expect(controller.state.sugestao, 'sugestão');
    expect(controller.state.errorMessage, isNull);
  });

  test('deveExporMensagemDeErroQuandoAChamadaFalha', () async {
    when(() => api.sugerir('trecho-1')).thenThrow(const NetworkException());

    final controller = RewriteController(api, 'trecho-1');
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.loading, isFalse);
    expect(controller.state.sugestao, isNull);
    expect(controller.state.errorMessage, isNotNull);
  });

  test('carregarNovamenteDeveRefazerAChamada', () async {
    when(
      () => api.sugerir('trecho-1'),
    ).thenThrow(const NetworkException());
    final controller = RewriteController(api, 'trecho-1');
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.errorMessage, isNotNull);

    when(() => api.sugerir('trecho-1')).thenAnswer((_) async => 'sugestão');
    await controller.carregar();

    expect(controller.state.sugestao, 'sugestão');
    expect(controller.state.errorMessage, isNull);
  });
}
