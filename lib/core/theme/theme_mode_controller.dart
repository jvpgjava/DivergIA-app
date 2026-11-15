import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/theme_preferences_storage.dart';

// O app sempre abre no tema claro; só muda se a pessoa escolher outro em Perfil → Tema.
// O valor salvo é lido em main() antes do primeiro frame (override deste provider), para
// quem escolheu escuro ou sistema não ver um clarão do tema claro na abertura.
final themeModeInicialProvider = Provider<ThemeMode>((ref) => ThemeMode.light);

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._storage, {ThemeMode inicial = ThemeMode.light})
    : super(inicial);

  final ThemePreferencesStorage _storage;

  Future<void> definir(ThemeMode modo) async {
    state = modo;
    await _storage.salvarModo(modo);
  }
}

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
      return ThemeModeController(
        ref.watch(themePreferencesStorageProvider),
        inicial: ref.watch(themeModeInicialProvider),
      );
    });
