import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
}

class LoadTasksRequested extends TaskEvent {
  final bool todayOnly;
  const LoadTasksRequested({this.todayOnly = false});
  @override
  List<Object?> get props => [todayOnly];
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
