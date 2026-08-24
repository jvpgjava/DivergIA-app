import 'package:divergia_app/core/theme/app_colors.dart';
import 'package:divergia_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme.light', () {
    test('deveUsarCorPrimariaEBackgroundDoFigma', () {
      final theme = AppTheme.light;

      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });

    test('deveEstilizarCampoDeTextoComoNoFigma', () {
      final theme = AppTheme.light;
      final border =
          theme.inputDecorationTheme.enabledBorder as OutlineInputBorder;

      expect(theme.inputDecorationTheme.fillColor, AppColors.surfaceInput);
      expect(border.borderSide.color, AppColors.border);
      expect(border.borderRadius, BorderRadius.circular(12));
    });
  });
}
