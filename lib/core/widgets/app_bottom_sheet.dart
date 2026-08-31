import 'package:flutter/material.dart';

import '../theme/app_color_tokens.dart';

/// Modal bottom sheet padronizado do app — cantos arredondados, alça de
/// arrastar e rolagem interna que evita o teclado, em vez do
/// [showModalBottomSheet] cru (cantos quadrados, sem alça, e sem rolagem —
/// o que causava overflow quando o teclado abria em cima de um formulário
/// com vários campos, como "Alterar senha").
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AppBottomSheetShell(builder: builder),
  );
}

class _AppBottomSheetShell extends StatelessWidget {
  const _AppBottomSheetShell({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Builder(builder: builder),
            ],
          ),
        ),
      ),
    );
  }
}
