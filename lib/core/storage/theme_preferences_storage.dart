import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferência local de tema — não é dado sensível, por isso usa
/// `shared_preferences` puro (o checklist de segurança do roadmap só exige
/// `flutter_secure_storage` para token/credencial).
class ThemePreferencesStorage {
  static const _modoEscuroKey = 'modo_escuro';

  Future<bool> lerModoEscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_modoEscuroKey) ?? false;
  }

  Future<void> salvarModoEscuro(bool escuro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modoEscuroKey, escuro);
  }
}

final themePreferencesStorageProvider = Provider<ThemePreferencesStorage>((
  ref,
) {
  return ThemePreferencesStorage();
});
