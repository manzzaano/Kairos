import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
}

class LoadTasksRequested extends TaskEvent {
  const LoadTasksRequested();
  @override
  List<Object?> get props => [];
}

class CreateTaskRequested extends TaskEvent {
  final TaskParams params;
  const CreateTaskRequested(this.params);
  @override
  List<Object?> get props => [params];
}

class ToggleTaskRequested extends TaskEvent {
  final String id;
  const ToggleTaskRequested({required this.id});
  @override
  List<Object?> get props => [id];
}

class DeleteTaskRequested extends TaskEvent {
  final String id;
  const DeleteTaskRequested({required this.id});
  @override
  List<Object?> get props => [id];
}

class ToggleSubtaskRequested extends TaskEvent {
  final String taskId;
  final int subtaskIndex;
  const ToggleSubtaskRequested({required this.taskId, required this.subtaskIndex});
  @override
  List<Object?> get props => [taskId, subtaskIndex];
}
