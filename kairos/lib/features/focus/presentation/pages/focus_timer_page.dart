import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _FocusTimerPageState extends State<FocusTimerPage>
    with TickerProviderStateMixin {
  Task? _task;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

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
    _pulseCtrl.dispose();
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

          final progress = 1.0 - (secondsLeft / FocusBloc.pomodoroSeconds);
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
              // Top bar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.pop();
                        },
                        child: Row(children: [
                          Icon(Icons.close, color: kc.text3, size: 18),
                          const SizedBox(width: 4),
                          Text('Salir',
                              style: AppTypography.body13
                                  .copyWith(color: kc.text3)),
                        ]),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x14FFFFFF),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text('POMODORO $round/4',
                            style: AppTypography.mono11
                                .copyWith(color: kc.text3)),
                      ),
                      const Spacer(),
                      const SizedBox(width: 60),
                    ],
                  ),
                ),
              ),

              // Task name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  children: [
                    Text('ENFOCADO EN',
                        style: AppTypography.mono11.copyWith(color: kc.accent)),
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

              // Timer ring
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  final pulseOpacity =
                      isRunning ? 0.15 + _pulseAnim.value * 0.12 : 0.0;
                  return SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring (pulse when running)
                        if (isRunning)
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      kc.accent.withValues(alpha: pulseOpacity),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        CustomPaint(
                          size: const Size(280, 280),
                          painter: _ArcPainter(
                            progress: progress,
                            accent: kc.accent,
                            isCompleted: isCompleted,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _fmt(secondsLeft),
                              style: AppTypography.mono64
                                  .copyWith(color: kc.text),
                            ),
                            const SizedBox(height: 8),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                isCompleted
                                    ? 'COMPLETADO'
                                    : isRunning
                                        ? 'EN PROGRESO'
                                        : 'EN PAUSA',
                                key: ValueKey(isCompleted
                                    ? 0
                                    : isRunning
                                        ? 1
                                        : 2),
                                style: AppTypography.mono11.copyWith(
                                    color: isCompleted
                                        ? kc.success
                                        : kc.text3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(),

              // Controls
              if (!isCompleted) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ControlBtn(
                      size: 56,
                      borderRadius: 18,
                      icon: Icons.sync,
                      bg: const Color(0xFF1A1A1A),
                      fg: kc.text,
                      border: const Color(0x26FFFFFF),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.read<FocusBloc>().add(const FocusReset());
                      },
                    ),
                    const SizedBox(width: AppSpacing.xxl),
                    _ControlBtn(
                      size: 76,
                      borderRadius: 26,
                      icon: isRunning ? Icons.pause : Icons.play_arrow,
                      bg: kc.accent,
                      fg: const Color(0xFF1A0A00),
                      shadow: kc.accent.withValues(alpha: 0.45),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        context
                            .read<FocusBloc>()
                            .add(const FocusTogglePause());
                      },
                    ),
                    const SizedBox(width: AppSpacing.xxl),
                    _ControlBtn(
                      size: 56,
                      borderRadius: 18,
                      icon: Icons.close,
                      bg: const Color(0xFF1A1A1A),
                      fg: kc.text,
                      border: const Color(0x26FFFFFF),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.pop();
                      },
                    ),
                  ],
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: _CompletedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        context.pop();
                      },
                      accent: kc.accent,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
              Text('NOTIFS PAUSADAS · +12 PUNTOS',
                  style: AppTypography.mono11.copyWith(color: kc.text4)),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}

/// Botón "¡Sesión completada!" con shimmer de entrada.
class _CompletedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color accent;
  const _CompletedButton({required this.onPressed, required this.accent});

  @override
  State<_CompletedButton> createState() => _CompletedButtonState();
}

class _CompletedButtonState extends State<_CompletedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '¡Sesión completada!',
              style: AppTypography.body15.copyWith(
                  color: const Color(0xFF1A0A00),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlBtn extends StatefulWidget {
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
  State<_ControlBtn> createState() => _ControlBtnState();
}

class _ControlBtnState extends State<_ControlBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.bg,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border != null
                ? Border.all(color: widget.border!)
                : null,
            boxShadow: widget.shadow != null
                ? [
                    BoxShadow(
                      color: widget.shadow!,
                      blurRadius: 32,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Icon(widget.icon,
              color: widget.fg, size: widget.size > 60 ? 32 : 22),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color accent;
  final bool isCompleted;
  const _ArcPainter({
    required this.progress,
    required this.accent,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Track ring
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0x14FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);

    if (isCompleted) {
      // Full circle glow for completed
      final glowPaint = Paint()
        ..color = accent.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, radius, glowPaint);

      final solidPaint = Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, solidPaint);
      return;
    }

    if (progress > 0) {
      // Glow layer
      final glowPaint = Paint()
        ..color = accent.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        progress * 2 * pi,
        false,
        glowPaint,
      );

      // Sharp arc
      final arcPaint = Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        progress * 2 * pi,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress ||
      old.accent != accent ||
      old.isCompleted != isCompleted;
}
