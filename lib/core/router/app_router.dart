import 'package:go_router/go_router.dart';

import '../../features/analysis/presentation/new_analysis_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../widgets/app_bottom_nav.dart';
import 'app_shell.dart';

/// Rotas principais do app. Todas apontam para telas placeholder além do
/// shell/bottom nav — o conteúdo real de cada uma chega na fase do roadmap
/// correspondente.
///
/// Uma função (em vez de uma instância global única) para que cada teste
/// possa montar seu próprio [GoRouter] isolado, sem herdar a localização
/// deixada por um teste anterior.
GoRouter buildAppRouter() => GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
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
      path: '/perfil',
      builder: (context, state) =>
          const AppShell(tab: AppNavTab.perfil, child: ProfileScreen()),
    ),
  ],
);
