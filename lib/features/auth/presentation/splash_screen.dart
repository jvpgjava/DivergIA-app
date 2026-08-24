import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Placeholder da Fase 0: só o essencial pra sair do lugar (marca + loading).
/// A arte final ("splash-screen" no Figma) e a checagem de sessão real
/// (ir para /historico se já houver token válido) chegam junto com a Fase 1
/// e a Fase 8, respectivamente — aqui sempre segue para /login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('DivergIA', style: AppTypography.displayLarge),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
