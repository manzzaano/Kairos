import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/features/tasks/domain/entities/task.dart' hide Task;
import 'package:kairos/features/tasks/domain/entities/task.dart' as task_entities show Task, Priority;
import 'package:kairos/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:kairos/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:kairos/features/tasks/domain/usecases/toggle_task_usecase.dart';
import 'package:kairos/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:kairos/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:kairos/features/tasks/presentation/bloc/task_event.dart';
import 'package:kairos/features/tasks/presentation/bloc/task_state.dart';
import 'package:kairos/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTasksUseCase extends Mock implements GetTasksUseCase {}
class MockCreateTaskUseCase extends Mock implements CreateTaskUseCase {}
class MockToggleTaskUseCase extends Mock implements ToggleTaskUseCase {}
class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

void main() {
  late TaskBloc taskBloc;
  late MockGetTasksUseCase mockGetTasksUseCase;

  const testTask = task_entities.Task(
    id: '1',
    title: 'Test Task',
    priority: task_entities.Priority.high,
    energyLevel: 5,
  );

  setUpAll(() {
    registerFallbackValue(const GetTasksParams());
  });

  setUp(() {
    mockGetTasksUseCase = MockGetTasksUseCase();
    taskBloc = TaskBloc(
      getTasksUseCase: mockGetTasksUseCase,
      createTaskUseCase: MockCreateTaskUseCase(),
      toggleTaskUseCase: MockToggleTaskUseCase(),
      deleteTaskUseCase: MockDeleteTaskUseCase(),
    );
  });

  tearDown(() => taskBloc.close());

  test('initial state is TaskInitial', () {
    expect(taskBloc.state, isA<TaskInitial>());
  });

  test('emits [TaskLoading, TaskLoaded] when load tasks succeeds', () async {
    when(() => mockGetTasksUseCase(any())).thenAnswer(
      (_) async => Right(<task_entities.Task>[testTask]), // ignore: prefer_const_constructors
    );

    taskBloc.add(const LoadTasksRequested());

    await Future.delayed(const Duration(milliseconds: 100));

    expect(taskBloc.state, isA<TaskLoaded>());
    if (taskBloc.state is TaskLoaded) {
      final loadedState = taskBloc.state as TaskLoaded;
      expect(loadedState.tasks.length, 1);
      expect(loadedState.tasks.first.title, 'Test Task');
    }
  });

  test('emits TaskError when load tasks fails', () async {
    when(() => mockGetTasksUseCase(any())).thenAnswer(
      (_) async => Left(CacheFailure('Failed to load')), // ignore: prefer_const_constructors
    );

    taskBloc.add(const LoadTasksRequested());

    await Future.delayed(const Duration(milliseconds: 100));

    expect(taskBloc.state, isA<TaskError>());
  });
}
