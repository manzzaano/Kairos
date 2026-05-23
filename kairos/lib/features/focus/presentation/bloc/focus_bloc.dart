import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'focus_event.dart';
import 'focus_state.dart';

class FocusBloc extends Bloc<FocusEvent, FocusState> {
  static const pomodoroSeconds = 25 * 60;
  Timer? _timer;
  int _currentRound = 1;

  FocusBloc() : super(const FocusIdle()) {
    on<FocusStart>(_onStart);
    on<FocusTogglePause>(_onTogglePause);
    on<FocusReset>(_onReset);
    on<FocusTick>(_onTick);
    on<FocusStop>(_onStop);
  }

  void _onStart(FocusStart event, Emitter<FocusState> emit) {
    _currentRound = 1;
    _startTimer();
    emit(FocusRunning(secondsLeft: pomodoroSeconds, task: event.task, round: _currentRound));
  }

  void _onTogglePause(FocusTogglePause event, Emitter<FocusState> emit) {
    if (state is FocusRunning) {
      _timer?.cancel();
      final running = state as FocusRunning;
      emit(FocusPaused(secondsLeft: running.secondsLeft, task: running.task, round: running.round));
    } else if (state is FocusPaused) {
      final paused = state as FocusPaused;
      _startTimer();
      emit(FocusRunning(secondsLeft: paused.secondsLeft, task: paused.task, round: paused.round));
    }
  }

  void _onReset(FocusReset event, Emitter<FocusState> emit) {
    _timer?.cancel();
    final current = state;
    final round = (current is FocusRunning) ? current.round
        : (current is FocusPaused) ? current.round : _currentRound;
    final task = current is FocusRunning ? current.task
        : current is FocusPaused ? current.task : null;
    _startTimer();
    emit(FocusRunning(secondsLeft: pomodoroSeconds, task: task, round: round));
  }

  void _onStop(FocusStop event, Emitter<FocusState> emit) {
    _timer?.cancel();
    emit(const FocusIdle());
  }

  void _onTick(FocusTick event, Emitter<FocusState> emit) {
    if (state is FocusRunning) {
      final current = state as FocusRunning;
      if (current.secondsLeft <= 1) {
        _timer?.cancel();
        _currentRound++;
        emit(FocusCompleted(round: current.round));
      } else {
        emit(FocusRunning(secondsLeft: current.secondsLeft - 1, task: current.task, round: current.round));
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => add(const FocusTick()));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
