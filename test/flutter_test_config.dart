import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Evita que os testes tentem buscar as fontes (Sora/Inter) pela rede —
/// usa o fallback local, deixando a suíte determinística e independente de
/// conexão (relevante também para a Fase 10, quando os testes rodarem no
/// agente Jenkins).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
