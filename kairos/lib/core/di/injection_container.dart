import 'package:get_it/get_it.dart';
import 'package:realm/realm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/tasks/data/datasources/task_realm_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/i_task_repository.dart';
import '../../features/tasks/domain/usecases/create_task_usecase.dart';
import '../../features/tasks/domain/usecases/delete_task_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../features/tasks/domain/usecases/toggle_task_usecase.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../../features/focus/presentation/bloc/focus_bloc.dart';
import '../../features/tasks/data/models/task_object.dart';
import '../theme/theme_cubit.dart';
import '../services/supabase_sync_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Supabase
  final supabaseClient = Supabase.instance.client;
  getIt.registerSingleton<SupabaseClient>(supabaseClient);
  getIt.registerSingleton<SupabaseSyncService>(
    SupabaseSyncService(supabase: supabaseClient),
  );

  // Realm — schema v1. En producción no borra datos en migración.
  final config = Configuration.local(
    [TaskObject.schema],
    schemaVersion: 1,
    shouldDeleteIfMigrationNeeded: false,
  );
  final realm = Realm(config);
  getIt.registerSingleton<Realm>(realm);

  // Tasks
  getIt.registerSingleton<TaskRealmDataSource>(
    TaskRealmDataSourceImpl(getIt<Realm>()),
  );
  getIt.registerSingleton<ITaskRepository>(
    TaskRepositoryImpl(realmDataSource: getIt<TaskRealmDataSource>()),
  );
  getIt.registerSingleton<GetTasksUseCase>(
    GetTasksUseCase(getIt<ITaskRepository>()),
  );
  getIt.registerSingleton<CreateTaskUseCase>(
    CreateTaskUseCase(getIt<ITaskRepository>()),
  );
  getIt.registerSingleton<ToggleTaskUseCase>(
    ToggleTaskUseCase(getIt<ITaskRepository>()),
  );
  getIt.registerSingleton<DeleteTaskUseCase>(
    DeleteTaskUseCase(getIt<ITaskRepository>()),
  );

  // BLoCs
  getIt.registerSingleton<TaskBloc>(
    TaskBloc(
      getTasksUseCase: getIt<GetTasksUseCase>(),
      createTaskUseCase: getIt<CreateTaskUseCase>(),
      toggleTaskUseCase: getIt<ToggleTaskUseCase>(),
      deleteTaskUseCase: getIt<DeleteTaskUseCase>(),
    ),
  );
  getIt.registerSingleton<FocusBloc>(FocusBloc());
  getIt.registerSingleton<ThemeCubit>(ThemeCubit());
}
