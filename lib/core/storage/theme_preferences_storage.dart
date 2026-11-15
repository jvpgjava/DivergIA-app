import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferencesStorage {
  static const _temaKey = 'tema';
  // Chave da versão antiga (só claro/escuro): quem já tinha escolhido o escuro continua no escuro.
  static const _modoEscuroLegadoKey = 'modo_escuro';

  Future<ThemeMode> lerModo() async {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(_temaKey)) {
      case 'escuro':
        return ThemeMode.dark;
      case 'sistema':
        return ThemeMode.system;
      case 'claro':
        return ThemeMode.light;
    }
    return (prefs.getBool(_modoEscuroLegadoKey) ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> salvarModo(ThemeMode modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_temaKey, switch (modo) {
      ThemeMode.dark => 'escuro',
      ThemeMode.system => 'sistema',
      ThemeMode.light => 'claro',
    });
  }
}

final themePreferencesStorageProvider = Provider<ThemePreferencesStorage>((
  ref,
) {
  return ThemePreferencesStorage();
});
