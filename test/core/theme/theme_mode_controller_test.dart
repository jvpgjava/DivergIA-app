import 'package:divergia_app/core/storage/theme_preferences_storage.dart';
import 'package:divergia_app/core/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockThemePreferencesStorage extends Mock
    implements ThemePreferencesStorage {}

void main() {
  late _MockThemePreferencesStorage storage;

  setUp(() {
    storage = _MockThemePreferencesStorage();
  });

  test('deveComecarNoClaroECarregarOModoEscuroSalvoAoSerCriado', () async {
    when(() => storage.lerModoEscuro()).thenAnswer((_) async => true);

    final controller = ThemeModeController(storage);
    expect(controller.state, ThemeMode.light);

    await Future<void>.delayed(Duration.zero);

    expect(controller.state, ThemeMode.dark);
  });

  test('deveContinuarNoClaroQuandoNaoHaPreferenciaSalva', () async {
    when(() => storage.lerModoEscuro()).thenAnswer((_) async => false);

    final controller = ThemeModeController(storage);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state, ThemeMode.light);
  });

  test('alternarDeveAtualizarOEstadoESalvarAPreferencia', () async {
    when(() => storage.lerModoEscuro()).thenAnswer((_) async => false);
    when(() => storage.salvarModoEscuro(any())).thenAnswer((_) async {});
    final controller = ThemeModeController(storage);
    await Future<void>.delayed(Duration.zero);

    await controller.alternar(true);

    expect(controller.state, ThemeMode.dark);
    verify(() => storage.salvarModoEscuro(true)).called(1);
  });
}
