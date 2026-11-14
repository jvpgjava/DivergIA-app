import 'package:flutter_riverpod/flutter_riverpod.dart';

// Sinal de que o histórico mudou (análise criada, histórico excluído). A lista e o
// painel de tendência ficam montados por baixo das telas empilhadas: sem este aviso,
// ao voltar eles mostrariam dados antigos.
final historicoAlteradoProvider = StateProvider<int>((ref) => 0);

void avisarHistoricoAlterado(WidgetRef ref) {
  ref.read(historicoAlteradoProvider.notifier).state++;
}
