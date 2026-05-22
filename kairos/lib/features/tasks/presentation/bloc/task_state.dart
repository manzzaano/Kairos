import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();
}

class TaskInitial extends TaskState {
  const TaskInitial();
  @override
  List<Object?> get props => [];
}

class TaskLoading extends TaskState {
  const TaskLoading();
  @override
  List<Object?> get props => [];
}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  const TaskLoaded({required this.tasks});
  @override
  List<Object?> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;
  const TaskError({required this.message});
  @override
  List<Object?> get props => [message];
}
