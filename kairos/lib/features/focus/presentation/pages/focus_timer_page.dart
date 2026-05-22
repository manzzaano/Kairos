import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/focus_bloc.dart';
import '../bloc/focus_event.dart';
import '../bloc/focus_state.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

class FocusTimerPage extends StatefulWidget {
  final String? taskId;
  const FocusTimerPage({this.taskId, super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> {
  Task? _task;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      final s = context.read<TaskBloc>().state;
      if (s is TaskLoaded) {
        _task = s.tasks.where((t) => t.id == widget.taskId).firstOrNull;
      }
    }
    context.read<FocusBloc>().add(FocusStart(task: _task));
  }

  @override
  void dispose() {
    context.read<FocusBloc>().add(const FocusStop());
    super.dispose();
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: BlocBuilder<FocusBloc, FocusState>(
        builder: (context, state) {
          final secondsLeft = state is FocusRunning
              ? state.secondsLeft
              : state is FocusPaused
                  ? state.secondsLeft
                  : state is FocusCompleted
                      ? 0
                      : FocusBloc.pomodoroSeconds;

          final progress =
              1.0 - (secondsLeft / FocusBloc.pomodoroSeconds);
          final isRunning = state is FocusRunning;
          final isCompleted = state is FocusCompleted;
          final task = state is FocusRunning
              ? state.task
              : state is FocusPaused
                  ? state.task
                  : _task;
          final round = state is FocusRunning
              ? state.round
              : state is FocusPaused
                  ? state.round
                  : state is FocusCompleted
                      ? state.round
                      : 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Row(children: [
                        Icon(Icons.close, color: kc.text3, size: 18),
                        const SizedBox(width: 4),
                        Text('Salir',
                            style: AppTypography.body13
                                .copyWith(color: kc.text3)),
                      ]),
                    ),
                    const Spacer(),
                    Text('POMODORO $round/4',
                        style: AppTypography.mono11
                            .copyWith(color: kc.text3)),
                    const Spacer(),
                    const SizedBox(width: 60),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    Text('ENFOCADO EN',
                        style: AppTypography.mono11
                            .copyWith(color: kc.accent)),
                    const SizedBox(height: 6),
                    Text(
                      task?.title ?? 'Sesión libre',
                      style: AppTypography.heading18,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(280, 280),
                      painter: _ArcPainter(
                        progress: progress,
                        accent: kc.accent,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_fmt(secondsLeft),
                            style: AppTypography.mono64
                                .copyWith(color: kc.text)),
                        const SizedBox(height: 8),
                        Text(
                          isCompleted
                              ? 'COMPLETADO'
                              : isRunning
                                  ? 'EN PROGRESO'
                                  : 'EN PAUSA',
                          style: AppTypography.mono11.copyWith(
                              color: isCompleted ? kc.success : kc.text3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              if (!isCompleted) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ControlBtn(
                      size: 52,
                      borderRadius: 16,
                      icon: Icons.sync,
                      bg: kc.bg2,
                      fg: kc.text,
                      border: kc.line,
                      onTap: () => context
                          .read<FocusBloc>()
                          .add(const FocusReset()),
                    ),
                    const SizedBox(width: AppSpacing.xxl),
                    _ControlBtn(
                      size: 72,
                      borderRadius: 24,
                      icon: isRunning ? Icons.pause : Icons.play_arrow,
                      bg: kc.accent,
                      fg: const Color(0xFF1A0A00),
                      shadow: kc.accent.withValues(alpha: 0.35),
                      onTap: () => context
                          .read<FocusBloc>()
                          .add(const FocusTogglePause()),
                    ),
                    const SizedBox(width: AppSpacing.xxl),
                    _ControlBtn(
                      size: 52,
                      borderRadius: 16,
                      icon: Icons.close,
                      bg: kc.bg2,
                      fg: kc.text,
                      border: kc.line,
                      onTap: () => context.pop(),
                    ),
                  ],
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kc.accent,
                  ),
                  child: Text('¡Sesión completada!',
                      style: AppTypography.body15
                          .copyWith(color: kc.bg)),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),
              Text('NOTIFS PAUSADAS · +12 PUNTOS',
                  style: AppTypography.mono11
                      .copyWith(color: kc.text4)),
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final double size;
  final double borderRadius;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color? border;
  final Color? shadow;
  final VoidCallback onTap;
  const _ControlBtn({
    required this.size,
    required this.borderRadius,
    required this.icon,
    required this.bg,
    required this.fg,
    this.border,
    this.shadow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border != null ? Border.all(color: border!) : null,
          boxShadow: shadow != null
              ? [
                  BoxShadow(
                    color: shadow!,
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: fg, size: size > 60 ? 32 : 20),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color accent;
  const _ArcPainter({required this.progress, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0x0DFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        progress * 2 * pi,
        false,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.accent != accent;
}
