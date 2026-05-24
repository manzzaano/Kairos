import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/toggle_task_usecase.dart';
import '../../domain/usecases/toggle_subtask_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase _getTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final ToggleTaskUseCase _toggleTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final ToggleSubtaskUseCase _toggleSubtaskUseCase;

  TaskBloc({
    required GetTasksUseCase getTasksUseCase,
    required CreateTaskUseCase createTaskUseCase,
    required ToggleTaskUseCase toggleTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required ToggleSubtaskUseCase toggleSubtaskUseCase,
  })  : _getTasksUseCase = getTasksUseCase,
        _createTaskUseCase = createTaskUseCase,
        _toggleTaskUseCase = toggleTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        _toggleSubtaskUseCase = toggleSubtaskUseCase,
        super(const TaskInitial()) {
    on<LoadTasksRequested>(_onLoadTasks);
    on<CreateTaskRequested>(_onCreateTask);
    on<ToggleTaskRequested>(_onToggleTask);
    on<DeleteTaskRequested>(_onDeleteTask);
    on<ToggleSubtaskRequested>(_onToggleSubtask);
  }

  Future<void> _onLoadTasks(
      LoadTasksRequested event, Emitter<TaskState> emit) async {
    emit(const TaskLoading());
    final result =
        await _getTasksUseCase(const GetTasksParams());
    emit(result.fold(
      (failure) => TaskError(message: failure.message),
      (tasks) => TaskLoaded(tasks: tasks),
    ));
  }

  Future<void> _onCreateTask(
      CreateTaskRequested event, Emitter<TaskState> emit) async {
    final result = await _createTaskUseCase(event.params);
    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (_) => add(const LoadTasksRequested()),
    );
  }

  Future<void> _onToggleTask(
      ToggleTaskRequested event, Emitter<TaskState> emit) async {
    final result = await _toggleTaskUseCase(event.id);
    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (_) => add(const LoadTasksRequested()),
    );
  }

  Future<void> _onDeleteTask(
      DeleteTaskRequested event, Emitter<TaskState> emit) async {
    final result = await _deleteTaskUseCase(event.id);
    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (_) => add(const LoadTasksRequested()),
    );
  }

  Future<void> _onToggleSubtask(
      ToggleSubtaskRequested event, Emitter<TaskState> emit) async {
    final result = await _toggleSubtaskUseCase(event.taskId, event.subtaskIndex);
    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (_) => add(const LoadTasksRequested()),
    );
  }
}
