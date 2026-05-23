import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/features/focus/presentation/bloc/focus_bloc.dart';
import 'package:kairos/features/focus/presentation/bloc/focus_event.dart';
import 'package:kairos/features/focus/presentation/bloc/focus_state.dart';

void main() {
  group('FocusBloc', () {
    late FocusBloc bloc;

    setUp(() => bloc = FocusBloc());
    tearDown(() => bloc.close());

    test('initial state is FocusIdle', () {
      expect(bloc.state, const FocusIdle());
    });

    test('FocusStart emits FocusRunning with full pomodoro seconds', () async {
      final states = <FocusState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FocusStart());
      await Future.delayed(Duration.zero);

      expect(states, hasLength(1));
      expect(states.first, isA<FocusRunning>());
      final running = states.first as FocusRunning;
      expect(running.secondsLeft, FocusBloc.pomodoroSeconds);
      expect(running.round, 1);

      await sub.cancel();
    });

    test('FocusTick decrements secondsLeft', () async {
      final states = <FocusState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FocusStart());
      bloc.add(const FocusTick());
      await Future.delayed(Duration.zero);

      final running = states.last as FocusRunning;
      expect(running.secondsLeft, FocusBloc.pomodoroSeconds - 1);

      await sub.cancel();
    });

    test('FocusTogglePause pauses running timer', () async {
      final states = <FocusState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FocusStart());
      bloc.add(const FocusTogglePause());
      await Future.delayed(Duration.zero);

      expect(states.last, isA<FocusPaused>());

      await sub.cancel();
    });

    test('FocusTogglePause resumes paused timer', () async {
      final states = <FocusState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FocusStart());
      bloc.add(const FocusTogglePause()); // pause
      bloc.add(const FocusTogglePause()); // resume
      await Future.delayed(Duration.zero);

      expect(states.last, isA<FocusRunning>());

      await sub.cancel();
    });

    test('FocusReset resets to full pomodoro', () async {
      final states = <FocusState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FocusStart());
      bloc.add(const FocusTick());
      bloc.add(const FocusReset());
      await Future.delayed(Duration.zero);

      final last = states.last as FocusRunning;
      expect(last.secondsLeft, FocusBloc.pomodoroSeconds);

      await sub.cancel();
    });

    test('FocusTick with 1 second left emits FocusCompleted', () async {
      // Seed the bloc at 1 second left by starting then ticking many times is slow.
      // Instead: start, verify state, then emit tick manually via internal path.
      // We test the _onTick handler by getting the bloc into FocusRunning(1) state first.
      final states = <FocusState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FocusStart());
      await Future.delayed(Duration.zero);

      // Manually drain secondsLeft to 1 via ticks
      const pomodoroSeconds = FocusBloc.pomodoroSeconds;
      for (int i = 0; i < pomodoroSeconds - 1; i++) {
        bloc.add(const FocusTick());
      }
      // Final tick → completed
      bloc.add(const FocusTick());
      await Future.delayed(Duration.zero);

      expect(states.last, isA<FocusCompleted>());

      await sub.cancel();
    });

    test('FocusStop emits FocusIdle', () async {
      final states = <FocusState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FocusStart());
      bloc.add(const FocusStop());
      await Future.delayed(Duration.zero);

      expect(states.last, const FocusIdle());

      await sub.cancel();
    });
  });
}
