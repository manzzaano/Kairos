import 'package:equatable/equatable.dart';
import 'package:kairos/features/tasks/domain/entities/task.dart';

abstract class FocusState extends Equatable {
  const FocusState();
}

class FocusIdle extends FocusState {
  const FocusIdle();
  @override List<Object?> get props => [];
}

class FocusRunning extends FocusState {
  final int secondsLeft;
  final Task? task;
  final int round;
  const FocusRunning({required this.secondsLeft, this.task, this.round = 1});
  @override List<Object?> get props => [secondsLeft, task, round];
}

class FocusPaused extends FocusState {
  final int secondsLeft;
  final Task? task;
  final int round;
  const FocusPaused({required this.secondsLeft, this.task, this.round = 1});
  @override List<Object?> get props => [secondsLeft, task, round];
}

class FocusCompleted extends FocusState {
  final int round;
  const FocusCompleted({this.round = 1});
  @override List<Object?> get props => [round];
}
