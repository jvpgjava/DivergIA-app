import 'package:divergia_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Roda no aparelho contra o backend real (adb reverse tcp:8080 tcp:8080):
// flutter test integration_test --dart-define=E2E_EMAIL=... --dart-define=E2E_SENHA=...
const _email = String.fromEnvironment('E2E_EMAIL');
const _senha = String.fromEnvironment('E2E_SENHA');

Future<void> esperar(WidgetTester tester, Finder alvo, {int segundos = 90}) async {
  final limite = DateTime.now().add(Duration(seconds: segundos));
  while (DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (alvo.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Não apareceu a tempo: $alvo');
}

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await esperar(tester, alvo);
  await tester.ensureVisible(alvo.first);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(alvo.first);
  await tester.pump(const Duration(milliseconds: 500));
}

Finder campoComDica(String dica) =>
    find.ancestor(of: find.text(dica), matching: find.byType(TextField));

Future<void> abrirNovaAnalise(WidgetTester tester) async {
  await tocar(tester, find.byIcon(LucideIcons.plus));
  await esperar(tester, find.text('Nova análise'));
}

Future<void> preencherAnalise(WidgetTester tester, String original, String editado) async {
  final campos = find.byType(TextField);
  await esperar(tester, campos);
  await tester.enterText(campos.at(0), original);
  await tester.enterText(campos.at(1), editado);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tocar(tester, find.text('Analisar textos'));
}

Future<void> voltar(WidgetTester tester) async {
  await tocar(tester, find.byIcon(LucideIcons.chevronLeft));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fluxo completo no aparelho real', (tester) async {
    app.main();
    await tester.pump(const Duration(seconds: 3));

    // Login (se a sessão salva não estiver ativa).
    final historico = find.text('Minhas análises');
    final entrar = find.text('Entrar');
    final limite = DateTime.now().add(const Duration(seconds: 20));
    while (historico.evaluate().isEmpty && entrar.evaluate().isEmpty && DateTime.now().isBefore(limite)) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    if (historico.evaluate().isEmpty) {
      await tester.enterText(campoComDica('seu@email.com'), _email);
      await tester.enterText(campoComDica('Sua senha secreta'), _senha);
      await tocar(tester, entrar);
    }
    await esperar(tester, historico);

    // 1) Binário: recusado no próprio app, sem ir ao servidor.
    await abrirNovaAnalise(tester);
    await preencherAnalise(tester, 'Sou contra essa proposta.',
        '01101111 01101100 01100001 00100000 01101101 01110101 01101110 01100100');
    await esperar(tester, find.textContaining('conteúdo codificado'));

    // 2) Idiomas diferentes: recusado pelo servidor (422) e mostrado na tela.
    await preencherAnalise(tester, 'Eu não concordo com essa proposta e vou votar contra ela na reunião.',
        'I do not agree with this proposal and I will vote against it in the meeting.');
    await esperar(tester, find.textContaining('idiomas diferentes'));

    // 3) Deriva de posição real: resultado com o trecho e a sugestão de reescrita.
    await preencherAnalise(
        tester, 'Sou contra essa proposta.', 'Essa proposta tem pontos que merecem ser considerados.');
    await esperar(tester, find.text('Sugerir reescrita fiel'));
    expect(find.textContaining('Posição'), findsWidgets);

    // 4) Reescrita: sugestões fiéis e aceitar.
    await tocar(tester, find.text('Sugerir reescrita fiel'));
    await esperar(tester, find.text('Aceitar sugestão'));
    await tocar(tester, find.text('Aceitar sugestão'));
    await esperar(tester, find.text('Sugerir reescrita fiel'));

    // 5) A análise recém-feita aparece na lista ao voltar, sem recarregar à mão.
    await voltar(tester);
    await esperar(tester, historico);
    await esperar(tester, find.textContaining('proposta'), segundos: 15);
    expect(find.textContaining('Nenhuma análise ainda'), findsNothing);

    // 6) Senha atual errada não desloga: mensagem clara e sessão mantida.
    await tocar(tester, find.text('Perfil'));
    await tocar(tester, find.text('Alterar senha'));
    await esperar(tester, campoComDica('Sua senha atual'));
    await tester.enterText(campoComDica('Sua senha atual'), 'senhaErradaQualquer1');
    await tester.enterText(campoComDica('Crie uma senha forte'), 'novaSenhaForte123');
    await tester.enterText(campoComDica('Repita a nova senha'), 'novaSenhaForte123');
    await tocar(tester, find.text('Salvar nova senha'));
    await esperar(tester, find.text('Senha atual incorreta.'));
    expect(find.text('Entrar'), findsNothing);
  });
}
