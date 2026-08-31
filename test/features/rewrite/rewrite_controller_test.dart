import 'package:divergia_app/core/network/api_exception.dart';
import 'package:divergia_app/features/rewrite/data/rewrite_api.dart';
import 'package:divergia_app/features/rewrite/presentation/rewrite_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRewriteApi extends Mock implements RewriteApi {}

void main() {
  late _MockRewriteApi api;

  const tresSugestoes = ['opção 1', 'opção 2', 'opção 3'];

  setUp(() {
    api = _MockRewriteApi();
    registerFallbackValue('');
  });

  test('deveCarregarAsTresSugestoesAutomaticamenteAoSerCriado', () async {
    when(() => api.sugerir('trecho-1')).thenAnswer((_) async => tresSugestoes);

    final controller = RewriteController(api, 'trecho-1');
    expect(controller.state.loading, isTrue);

    await Future<void>.delayed(Duration.zero);

    expect(controller.state.loading, isFalse);
    expect(controller.state.sugestoes, tresSugestoes);
    expect(controller.state.indiceSelecionado, 0);
    expect(controller.state.errorMessage, isNull);
  });

  test('deveExporMensagemDeErroQuandoAChamadaFalha', () async {
    when(() => api.sugerir('trecho-1')).thenThrow(const NetworkException());

    final controller = RewriteController(api, 'trecho-1');
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.loading, isFalse);
    expect(controller.state.sugestoes, isEmpty);
    expect(controller.state.errorMessage, isNotNull);
  });

  test('carregarNovamenteDeveRefazerAChamada', () async {
    when(() => api.sugerir('trecho-1')).thenThrow(const NetworkException());
    final controller = RewriteController(api, 'trecho-1');
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.errorMessage, isNotNull);

    when(() => api.sugerir('trecho-1')).thenAnswer((_) async => tresSugestoes);
    await controller.carregar();

    expect(controller.state.sugestoes, tresSugestoes);
    expect(controller.state.errorMessage, isNull);
  });

  test('selecionarDeveTrocarOIndiceSelecionado', () async {
    when(() => api.sugerir('trecho-1')).thenAnswer((_) async => tresSugestoes);
    final controller = RewriteController(api, 'trecho-1');
    await Future<void>.delayed(Duration.zero);

    controller.selecionar(2);

    expect(controller.state.indiceSelecionado, 2);
  });

  test(
    'aceitarDeveChamarAApiComASugestaoSelecionadaEDevolverTrue',
    () async {
      when(
        () => api.sugerir('trecho-1'),
      ).thenAnswer((_) async => tresSugestoes);
      when(
        () => api.aceitar('trecho-1', any(that: isA<String>())),
      ).thenAnswer((_) async {});

      final controller = RewriteController(api, 'trecho-1');
      await Future<void>.delayed(Duration.zero);
      controller.selecionar(1);

      final sucesso = await controller.aceitar();

      expect(sucesso, isTrue);
      verify(() => api.aceitar('trecho-1', 'opção 2')).called(1);
    },
  );

  test(
    'aceitarDeveExporErroEDevolverFalseQuandoAChamadaFalha',
    () async {
      when(
        () => api.sugerir('trecho-1'),
      ).thenAnswer((_) async => tresSugestoes);
      when(
        () => api.aceitar('trecho-1', any(that: isA<String>())),
      ).thenThrow(const NetworkException());

      final controller = RewriteController(api, 'trecho-1');
      await Future<void>.delayed(Duration.zero);

      final sucesso = await controller.aceitar();

      expect(sucesso, isFalse);
      expect(controller.state.aceitando, isFalse);
      expect(controller.state.errorMessage, isNotNull);
    },
  );
}
