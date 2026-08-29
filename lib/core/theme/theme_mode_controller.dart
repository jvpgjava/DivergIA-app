import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/theme_preferences_storage.dart';

/// Preferência de "modo escuro" do Figma é um único switch (sem opção de
/// "seguir o sistema"), então o estado é sempre [ThemeMode.light] ou
/// [ThemeMode.dark] — nunca [ThemeMode.system].
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._storage) : super(ThemeMode.light) {
    _carregar();
  }

  final ThemePreferencesStorage _storage;

  Future<void> _carregar() async {
    final escuro = await _storage.lerModoEscuro();
    state = escuro ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> alternar(bool escuro) async {
    state = escuro ? ThemeMode.dark : ThemeMode.light;
    await _storage.salvarModoEscuro(escuro);
  }
}

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
      return ThemeModeController(ref.watch(themePreferencesStorageProvider));
    });
