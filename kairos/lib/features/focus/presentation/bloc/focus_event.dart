import 'package:equatable/equatable.dart';
import 'package:kairos/features/tasks/domain/entities/task.dart' as task_entity;

abstract class FocusEvent extends Equatable {
  const FocusEvent();
}

class FocusStart extends FocusEvent {
  final task_entity.Task? task;
  const FocusStart({this.task});
  @override List<Object?> get props => [task];
}

class FocusTogglePause extends FocusEvent {
  const FocusTogglePause();
  @override List<Object?> get props => [];
}

class FocusReset extends FocusEvent {
  const FocusReset();
  @override List<Object?> get props => [];
}

class FocusStop extends FocusEvent {
  const FocusStop();
  @override List<Object?> get props => [];
}

class FocusTick extends FocusEvent {
  const FocusTick();
  @override List<Object?> get props => [];
}
