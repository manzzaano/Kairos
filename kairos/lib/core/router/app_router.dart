import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/tasks/presentation/pages/task_list_page.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';
import '../../features/tasks/presentation/pages/create_task_page.dart';
import '../../features/focus/presentation/pages/focus_page.dart';
import '../../features/focus/presentation/pages/focus_timer_page.dart';
import '../../features/stats/presentation/pages/stats_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/login_page.dart';
import '../../features/optimize/presentation/pages/optimize_page.dart';
import '../../features/app/presentation/pages/app_shell.dart';

/// Notifica al router cuando cambia el estado de auth de Supabase.
class _SupabaseAuthNotifier extends ChangeNotifier {
  _SupabaseAuthNotifier() {
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
}

class AppRouter {
  static final _authNotifier = _SupabaseAuthNotifier();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _authNotifier,
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final loc = state.matchedLocation;

      // Si ya está autenticado y está en /login, llevar al dashboard
      if (user != null && loc == '/login') return '/dashboard';

      // No bloqueamos rutas principales — la app funciona en modo offline/guest
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/create-task',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateTaskPage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 200),
        ),
      ),
      GoRoute(
        path: '/task/:id',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: TaskDetailPage(taskId: state.pathParameters['id']!),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 200),
        ),
      ),
      GoRoute(
        path: '/focus/timer',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: FocusTimerPage(taskId: state.uri.queryParameters['taskId']),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 200),
        ),
      ),
      GoRoute(
        path: '/optimize',
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OptimizePage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/dashboard',
                builder: (_, __) => const DashboardPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/tasks', builder: (_, __) => const TaskListPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/focus', builder: (_, __) => const FocusPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/stats', builder: (_, __) => const StatsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          ]),
        ],
      ),
    ],
  );
}
