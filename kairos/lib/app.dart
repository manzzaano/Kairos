import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/di/injection_container.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';
import 'features/focus/presentation/bloc/focus_bloc.dart';

class KairosApp extends StatelessWidget {
  const KairosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => getIt<ThemeCubit>()..load(),
        ),
        BlocProvider<TaskBloc>(create: (_) => getIt<TaskBloc>()),
        BlocProvider<FocusBloc>(create: (_) => getIt<FocusBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (_, themeState) => MaterialApp.router(
          title: 'KAIROS',
          theme: AppTheme.light(themeState.accent),
          darkTheme: AppTheme.dark(themeState.accent),
          themeMode: themeState.mode,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
