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
import '../../features/tasks/domain/usecases/toggle_subtask_usecase.dart';
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

  // Realm — schema v2 (añade subtasks + subtasksDone).
  // migrationCallback requerido cuando schemaVersion sube sin borrar datos.
  // Las RealmList nuevas se inicializan vacías automáticamente para registros v1.
  final config = Configuration.local(
    [TaskObject.schema],
    schemaVersion: 2,
    migrationCallback: (migration, oldSchemaVersion) {
      // v1 → v2: se añaden subtasks (List<String>) y subtasksDone (List<bool>).
      // Realm inicializa listas vacías para objetos existentes — sin acción manual.
    },
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
  getIt.registerSingleton<ToggleSubtaskUseCase>(
    ToggleSubtaskUseCase(getIt<ITaskRepository>()),
  );

  // BLoCs
  getIt.registerSingleton<TaskBloc>(
    TaskBloc(
      getTasksUseCase: getIt<GetTasksUseCase>(),
      createTaskUseCase: getIt<CreateTaskUseCase>(),
      toggleTaskUseCase: getIt<ToggleTaskUseCase>(),
      deleteTaskUseCase: getIt<DeleteTaskUseCase>(),
      toggleSubtaskUseCase: getIt<ToggleSubtaskUseCase>(),
    ),
  );
  getIt.registerSingleton<FocusBloc>(FocusBloc());
  getIt.registerSingleton<ThemeCubit>(ThemeCubit());
}
