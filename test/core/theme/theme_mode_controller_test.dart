import 'package:divergia_app/core/storage/theme_preferences_storage.dart';
import 'package:divergia_app/core/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockThemePreferencesStorage extends Mock
    implements ThemePreferencesStorage {}

void main() {
  late _MockThemePreferencesStorage storage;

  setUpAll(() => registerFallbackValue(ThemeMode.light));

  setUp(() {
    storage = _MockThemePreferencesStorage();
    when(() => storage.salvarModo(any())).thenAnswer((_) async {});
  });

  test('deveAbrirNoTemaClaroPorPadrao', () {
    expect(ThemeModeController(storage).state, ThemeMode.light);
  });

  test('deveComecarNoModoSalvoQuandoOMainJaLeuAsPreferencias', () {
    expect(
      ThemeModeController(storage, inicial: ThemeMode.system).state,
      ThemeMode.system,
    );
  });

  test('definirDeveTrocarOModoESalvar', () async {
    final controller = ThemeModeController(storage);

    for (final modo in [ThemeMode.dark, ThemeMode.system, ThemeMode.light]) {
      await controller.definir(modo);
      expect(controller.state, modo);
      verify(() => storage.salvarModo(modo)).called(1);
    }
  });

  test('providerUsaOModoInicialInjetadoPeloMain', () {
    final container = ProviderContainer(
      overrides: [themeModeInicialProvider.overrideWithValue(ThemeMode.dark)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });

  group('ThemePreferencesStorage', () {
    late ThemePreferencesStorage real;

    setUp(() => real = ThemePreferencesStorage());

    test('semNadaSalvoOPadraoEClaro', () async {
      SharedPreferences.setMockInitialValues({});

      expect(await real.lerModo(), ThemeMode.light);
    });

    test('guardaERecuperaAsTresOpcoes', () async {
      SharedPreferences.setMockInitialValues({});

      for (final modo in ThemeMode.values) {
        await real.salvarModo(modo);
        expect(await real.lerModo(), modo);
      }
    });

    test('quemJaTinhaEscolhidoOEscuroNaVersaoAntigaContinuaNoEscuro', () async {
      SharedPreferences.setMockInitialValues({'modo_escuro': true});

      expect(await real.lerModo(), ThemeMode.dark);
    });

    test('aEscolhaNovaTemPrioridadeSobreAChaveAntiga', () async {
      SharedPreferences.setMockInitialValues({
        'modo_escuro': true,
        'tema': 'claro',
      });

      expect(await real.lerModo(), ThemeMode.light);
    });
  });
}
