import 'package:divergia_app/core/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required AppNavTab selected,
    required VoidCallback onHistorico,
    required VoidCallback onNovaAnalise,
    required VoidCallback onPerfil,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            selected: selected,
            onHistoricoTap: onHistorico,
            onNovaAnaliseTap: onNovaAnalise,
            onPerfilTap: onPerfil,
          ),
        ),
      ),
    );
  }

  testWidgets('deveExibirAsTresAcoesDaBottomNav', (tester) async {
    await pump(
      tester,
      selected: AppNavTab.historico,
      onHistorico: () {},
      onNovaAnalise: () {},
      onPerfil: () {},
    );

    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('deveChamarCallbackAoTocarEmHistorico', (tester) async {
    var tapped = false;
    await pump(
      tester,
      selected: AppNavTab.perfil,
      onHistorico: () => tapped = true,
      onNovaAnalise: () {},
      onPerfil: () {},
    );

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('deveChamarCallbackAoTocarEmNovaAnalise', (tester) async {
    var tapped = false;
    await pump(
      tester,
      selected: AppNavTab.historico,
      onHistorico: () {},
      onNovaAnalise: () => tapped = true,
      onPerfil: () {},
    );

    await tester.tap(find.byIcon(LucideIcons.plus));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
