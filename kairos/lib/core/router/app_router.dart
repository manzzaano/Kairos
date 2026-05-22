import 'package:go_router/go_router.dart';
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

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
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
        builder: (_, __) => const CreateTaskPage(),
      ),
      GoRoute(
        path: '/task/:id',
        builder: (_, state) =>
            TaskDetailPage(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/focus/timer',
        builder: (_, state) =>
            FocusTimerPage(taskId: state.uri.queryParameters['taskId']),
      ),
      GoRoute(
        path: '/optimize',
        builder: (_, __) => const OptimizePage(),
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
            GoRoute(
                path: '/tasks', builder: (_, __) => const TaskListPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/focus', builder: (_, __) => const FocusPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/stats', builder: (_, __) => const StatsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/profile', builder: (_, __) => const ProfilePage()),
          ]),
        ],
      ),
    ],
  );
}
