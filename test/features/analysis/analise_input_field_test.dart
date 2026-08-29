import 'dart:typed_data';

import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:divergia_app/features/analysis/data/models/arquivo_selecionado.dart';
import 'package:divergia_app/features/analysis/presentation/widgets/analise_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  Widget build({
    required TextEditingController controller,
    ArquivoSelecionado? arquivo,
    String? errorText,
    VoidCallback? onAnexar,
    VoidCallback? onRemoverArquivo,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: AnaliseInputField(
          label: 'Texto original',
          hint: 'Cole aqui...',
          controller: controller,
          arquivo: arquivo,
          errorText: errorText,
          onAnexar: onAnexar ?? () {},
          onRemoverArquivo: onRemoverArquivo ?? () {},
        ),
      ),
    );
  }

  testWidgets('deveMostrarContadorDeCaracteresAtualizandoAoDigitar', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(build(controller: controller));

    expect(find.text('0 / 1000 caract.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();

    expect(find.text('3 / 1000 caract.'), findsOneWidget);
  });

  testWidgets('deveMostrarMensagemDeErroQuandoInformada', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      build(controller: controller, errorText: 'Campo obrigatório'),
    );

    expect(find.text('Campo obrigatório'), findsOneWidget);
  });

  testWidgets('deveMostrarCardDoArquivoEEsconderATextareaQuandoHaArquivo', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      build(
        controller: controller,
        arquivo: ArquivoSelecionado(nome: 'documento.pdf', bytes: Uint8List(0)),
      ),
    );

    expect(find.text('documento.pdf'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Remover arquivo'), findsOneWidget);
  });

  testWidgets('deveChamarOnRemoverArquivoAoTocarNoLink', (tester) async {
    var removeu = false;
    final controller = TextEditingController();
    await tester.pumpWidget(
      build(
        controller: controller,
        arquivo: ArquivoSelecionado(nome: 'documento.pdf', bytes: Uint8List(0)),
        onRemoverArquivo: () => removeu = true,
      ),
    );

    await tester.tap(find.text('Remover arquivo'));
    await tester.pump();

    expect(removeu, isTrue);
  });

  testWidgets('deveChamarOnAnexarAoTocarNoIconeDeAnexo', (tester) async {
    var anexou = false;
    final controller = TextEditingController();
    await tester.pumpWidget(
      build(controller: controller, onAnexar: () => anexou = true),
    );

    await tester.tap(find.byIcon(LucideIcons.paperclip));
    await tester.pump();

    expect(anexou, isTrue);
  });
}
