import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/storage/theme_preferences_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var tema = ThemeMode.light;
  try {
    tema = await ThemePreferencesStorage().lerModo();
  } catch (_) {
    // Sem acesso às preferências, abre no tema claro (o padrão).
  }
  runApp(
    ProviderScope(
      overrides: [themeModeInicialProvider.overrideWithValue(tema)],
      child: const DivergiaApp(),
    ),
  );
}

class DivergiaApp extends ConsumerWidget {
  const DivergiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'DivergIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeControllerProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
