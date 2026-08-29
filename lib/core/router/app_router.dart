import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analysis/presentation/analysis_result_screen.dart';
import '../../features/analysis/presentation/new_analysis_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/session_controller.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../widgets/app_bottom_nav.dart';
import 'app_shell.dart';

const _rotasPublicas = {
  '/login',
  '/signup',
  '/esqueci-senha',
  '/redefinir-senha',
};

/// Rotas principais do app. `redirect` protege as rotas autenticadas e
/// manda quem já está logado direto pro histórico, com base no
/// [SessionController] (que também dispara o recheck via
/// `refreshListenable`, sem recriar o [GoRouter] inteiro a cada mudança de
/// sessão).
///
/// Uma função (em vez de uma instância global única) para que cada teste
/// possa montar seu próprio [GoRouter] isolado, sem herdar a localização
/// deixada por um teste anterior.
GoRouter buildAppRouter(SessionController sessionController) => GoRouter(
  initialLocation: '/splash',
  refreshListenable: sessionController,
  redirect: (context, state) {
    final location = state.matchedLocation;
    switch (sessionController.status) {
      case SessionStatus.checking:
        return location == '/splash' ? null : '/splash';
      case SessionStatus.unauthenticated:
        if (location == '/splash') return '/login';
        return _rotasPublicas.contains(location) ? null : '/login';
      case SessionStatus.authenticated:
        if (location == '/splash' || _rotasPublicas.contains(location)) {
          return '/historico';
        }
        return null;
    }
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/esqueci-senha',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/redefinir-senha',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/nova-analise',
      builder: (context, state) => const NewAnalysisScreen(),
    ),
    GoRoute(
      path: '/historico',
      builder: (context, state) =>
          const AppShell(tab: AppNavTab.historico, child: HistoryScreen()),
    ),
    GoRoute(
      path: '/historico/:id',
      builder: (context, state) =>
          AnalysisResultScreen(analiseId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/perfil',
      builder: (context, state) =>
          const AppShell(tab: AppNavTab.perfil, child: ProfileScreen()),
    ),
  ],
);

/// `ref.read` (não `watch`) de propósito: o próprio [GoRouter] já escuta o
/// [SessionController] via `refreshListenable` para reavaliar o
/// `redirect` — se este provider desse `watch`, o router inteiro seria
/// recriado a cada mudança de sessão, perdendo a pilha de navegação.
final routerProvider = Provider<GoRouter>((ref) {
  return buildAppRouter(ref.read(sessionControllerProvider));
});
