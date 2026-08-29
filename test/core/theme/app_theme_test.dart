import 'package:divergia_app/core/theme/app_color_tokens.dart';
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
      expect(theme.scaffoldBackgroundColor, AppColorTokens.light.background);
      expect(theme.extension<AppColorTokens>(), AppColorTokens.light);
    });

    test('deveEstilizarCampoDeTextoComoNoFigma', () {
      final theme = AppTheme.light;
      final border =
          theme.inputDecorationTheme.enabledBorder as OutlineInputBorder;

      expect(
        theme.inputDecorationTheme.fillColor,
        AppColorTokens.light.surfaceInput,
      );
      expect(border.borderSide.color, AppColorTokens.light.border);
      expect(border.borderRadius, BorderRadius.circular(12));
    });
  });

  group('AppTheme.dark', () {
    test('deveUsarAPaletaEscuraExtraidaDoFigma', () {
      final theme = AppTheme.dark;

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColorTokens.dark.background);
      expect(theme.extension<AppColorTokens>(), AppColorTokens.dark);
    });

    test('deveEstilizarCampoDeTextoComAsCoresEscuras', () {
      final theme = AppTheme.dark;
      final border =
          theme.inputDecorationTheme.enabledBorder as OutlineInputBorder;

      expect(
        theme.inputDecorationTheme.fillColor,
        AppColorTokens.dark.surfaceInput,
      );
      expect(border.borderSide.color, AppColorTokens.dark.border);
    });
  });
}
