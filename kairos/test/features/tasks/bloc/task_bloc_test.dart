import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/features/tasks/domain/entities/task.dart' hide Task;
import 'package:kairos/features/tasks/domain/entities/task.dart' as task_entities show Task, Priority;
import 'package:kairos/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:kairos/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:kairos/features/tasks/domain/usecases/toggle_task_usecase.dart';
import 'package:kairos/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:kairos/features/tasks/domain/usecases/toggle_subtask_usecase.dart';
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
class MockToggleSubtaskUseCase extends Mock implements ToggleSubtaskUseCase {}

void main() {
  late TaskBloc taskBloc;
  late MockGetTasksUseCase mockGetTasksUseCase;
  late MockCreateTaskUseCase mockCreateTaskUseCase;
  late MockToggleTaskUseCase mockToggleTaskUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;
  late MockToggleSubtaskUseCase mockToggleSubtaskUseCase;

  const testTask = task_entities.Task(
    id: 'abc-123',
    title: 'Test Task',
    priority: task_entities.Priority.high,
    energyLevel: 5,
  );

  const testParams = TaskParams(
    title: 'Test Task',
    priority: task_entities.Priority.high,
    energyLevel: 5,
  );

  setUpAll(() {
    registerFallbackValue(const GetTasksParams());
    registerFallbackValue(testParams);
    registerFallbackValue('abc-123');
  });

  setUp(() {
    mockGetTasksUseCase = MockGetTasksUseCase();
    mockCreateTaskUseCase = MockCreateTaskUseCase();
    mockToggleTaskUseCase = MockToggleTaskUseCase();
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();
    mockToggleSubtaskUseCase = MockToggleSubtaskUseCase();
    taskBloc = TaskBloc(
      getTasksUseCase: mockGetTasksUseCase,
      createTaskUseCase: mockCreateTaskUseCase,
      toggleTaskUseCase: mockToggleTaskUseCase,
      deleteTaskUseCase: mockDeleteTaskUseCase,
      toggleSubtaskUseCase: mockToggleSubtaskUseCase,
    );
  });

  tearDown(() => taskBloc.close());

  // ── Estado inicial ──────────────────────────────────────────────────────────

  test('initial state is TaskInitial', () {
    expect(taskBloc.state, isA<TaskInitial>());
  });

  // ── LoadTasksRequested ──────────────────────────────────────────────────────

  test('emits [TaskLoading, TaskLoaded] when load tasks succeeds', () async {
    when(() => mockGetTasksUseCase(any())).thenAnswer(
      (_) async => const Right(<task_entities.Task>[testTask]),
    );

    taskBloc.add(const LoadTasksRequested());
    await Future.delayed(const Duration(milliseconds: 100));

    expect(taskBloc.state, isA<TaskLoaded>());
    final loaded = taskBloc.state as TaskLoaded;
    expect(loaded.tasks.length, 1);
    expect(loaded.tasks.first.title, 'Test Task');
  });

  test('emits TaskError when load tasks fails', () async {
    when(() => mockGetTasksUseCase(any())).thenAnswer(
      (_) async => const Left(CacheFailure('Failed to load')),
    );

    taskBloc.add(const LoadTasksRequested());
    await Future.delayed(const Duration(milliseconds: 100));

    expect(taskBloc.state, isA<TaskError>());
    final error = taskBloc.state as TaskError;
    expect(error.message, 'Failed to load');
  });

  // ── CreateTaskRequested ─────────────────────────────────────────────────────

  test('CreateTaskRequested → crea y recarga lista', () async {
    // El create devuelve la nueva tarea
    when(() => mockCreateTaskUseCase(any()))
        .thenAnswer((_) async => const Right(testTask));
    // El reload posterior devuelve la lista actualizada
    when(() => mockGetTasksUseCase(any()))
        .thenAnswer((_) async => const Right(<task_entities.Task>[testTask]));

    taskBloc.add(const CreateTaskRequested(testParams));
    await Future.delayed(const Duration(milliseconds: 200));

    expect(taskBloc.state, isA<TaskLoaded>());
    verify(() => mockCreateTaskUseCase(any())).called(1);
  });

  test('CreateTaskRequested falla → emite TaskError', () async {
    when(() => mockCreateTaskUseCase(any()))
        .thenAnswer((_) async => const Left(CacheFailure('Create failed')));

    taskBloc.add(const CreateTaskRequested(testParams));
    await Future.delayed(const Duration(milliseconds: 100));

    expect(taskBloc.state, isA<TaskError>());
  });

  // ── ToggleTaskRequested ─────────────────────────────────────────────────────

  test('ToggleTaskRequested → toggle y recarga lista', () async {
    when(() => mockToggleTaskUseCase(any()))
        .thenAnswer((_) async => const Right(testTask));
    when(() => mockGetTasksUseCase(any()))
        .thenAnswer((_) async => const Right(<task_entities.Task>[testTask]));

    taskBloc.add(const ToggleTaskRequested(id: 'abc-123'));
    await Future.delayed(const Duration(milliseconds: 200));

    expect(taskBloc.state, isA<TaskLoaded>());
    verify(() => mockToggleTaskUseCase('abc-123')).called(1);
  });

  // ── DeleteTaskRequested ─────────────────────────────────────────────────────

  test('DeleteTaskRequested → elimina y recarga lista vacía', () async {
    when(() => mockDeleteTaskUseCase(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockGetTasksUseCase(any()))
        .thenAnswer((_) async => const Right(<task_entities.Task>[]));

    taskBloc.add(const DeleteTaskRequested(id: 'abc-123'));
    await Future.delayed(const Duration(milliseconds: 200));

    expect(taskBloc.state, isA<TaskLoaded>());
    final loaded = taskBloc.state as TaskLoaded;
    expect(loaded.tasks, isEmpty);
    verify(() => mockDeleteTaskUseCase('abc-123')).called(1);
  });

  // ── ToggleSubtaskRequested ──────────────────────────────────────────────────

  test('ToggleSubtaskRequested → toggle subtarea y recarga', () async {
    const taskWithSubtasks = task_entities.Task(
      id: 'abc-123',
      title: 'Task con subtareas',
      priority: task_entities.Priority.low,
      energyLevel: 2,
      subtasks: ['Subtarea 1'],
      subtasksDone: [true],
    );
    when(() => mockToggleSubtaskUseCase(any(), any()))
        .thenAnswer((_) async => const Right(taskWithSubtasks));
    when(() => mockGetTasksUseCase(any())).thenAnswer(
        (_) async => const Right(<task_entities.Task>[taskWithSubtasks]));

    taskBloc.add(const ToggleSubtaskRequested(taskId: 'abc-123', subtaskIndex: 0));
    await Future.delayed(const Duration(milliseconds: 200));

    expect(taskBloc.state, isA<TaskLoaded>());
  });
}
