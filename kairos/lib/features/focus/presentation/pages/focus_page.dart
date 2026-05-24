import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/k_screen.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});
  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasksRequested());
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          final allTasks = state is TaskLoaded ? state.tasks : <Task>[];
          final pending = allTasks.where((t) => !t.isDone).take(4).toList();

          final today = DateTime.now();
          final todayStart = DateTime(today.year, today.month, today.day);
          final completedTodayTasks = allTasks.where((t) =>
              t.isDone &&
              t.completedAt != null &&
              !t.completedAt!.isBefore(todayStart));
          final completedToday = completedTodayTasks.length;
          final totalTimeMinutes = completedTodayTasks
              .fold<int>(0, (sum, t) => sum + t.estimateMinutes);
          final hours = totalTimeMinutes ~/ 60;
          final mins = totalTimeMinutes % 60;
          final timeLabel = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                KScreen.hPad(context), KScreen.topPad(context),
                KScreen.hPad(context), KScreen.bottomPad(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kc.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: kc.accent.withValues(alpha: 0.3)),
                      ),
                      child: Text('DEEP WORK',
                          style: AppTypography.mono11.copyWith(
                              color: kc.accent, fontWeight: FontWeight.w700)),
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms),
                const SizedBox(height: AppSpacing.md),
                Text('Modo enfoque', style: AppTypography.heading28)
                    .animate()
                    .fadeIn(delay: 60.ms, duration: 350.ms)
                    .slideY(begin: -0.05, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.sm),
                Text(
                    'Una tarea. Un cronómetro. Sin distracciones.',
                    style: AppTypography.body14.copyWith(color: kc.text2))
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 350.ms),
                const SizedBox(height: AppSpacing.xxl),

                // CTA button con glow pulsante
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, child) {
                    final g = CurvedAnimation(
                      parent: _pulseCtrl,
                      curve: Curves.easeInOut,
                    ).value;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: kc.accent.withValues(alpha: 0.25 + g * 0.15),
                            blurRadius: 20 + g * 12,
                            spreadRadius: g * 2,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kc.accent, kc.accent.withValues(alpha: 0.75)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.push('/focus/timer');
                        },
                        icon: const Icon(Icons.play_arrow_rounded,
                            color: Color(0xFF1A0A00), size: 20),
                        label: Text('Empezar sesión libre',
                            style: AppTypography.body15.copyWith(
                                color: const Color(0xFF1A0A00),
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms)
                .slideY(begin: 0.08, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.xxl),

                if (pending.isNotEmpty) ...[
                  Row(children: [
                    Expanded(
                      child: Divider(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.08)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('O ENFÓCATE EN UNA TAREA',
                          style: AppTypography.mono11.copyWith(color: kc.text3)),
                    ),
                    Expanded(
                      child: Divider(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.08)),
                    ),
                  ])
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 300.ms),
                  const SizedBox(height: AppSpacing.lg),
                  for (int i = 0; i < pending.length; i++)
                    _FocusTaskCard(task: pending[i], index: i),
                ],

                const SizedBox(height: AppSpacing.xxl),

                // Stats card glassmorphism
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.055)
                            : Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                                alpha: isDark ? 0.15 : 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.today_rounded, size: 13, color: kc.accent),
                              const SizedBox(width: 6),
                              Text('HOY',
                                  style: AppTypography.mono11.copyWith(color: kc.text3)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              _StatItem(
                                label: 'Sesiones',
                                value: '${pending.length}',
                                color: kc.accent,
                              ),
                              const SizedBox(width: AppSpacing.xxl),
                              _StatItem(
                                label: 'Tiempo',
                                value: timeLabel,
                                color: kc.success,
                              ),
                              const SizedBox(width: AppSpacing.xxl),
                              _StatItem(
                                label: 'Completadas',
                                value: '$completedToday',
                                color: kc.warning,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.08, curve: Curves.easeOut),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FocusTaskCard extends StatefulWidget {
  final Task task;
  final int index;
  const _FocusTaskCard({required this.task, required this.index});

  @override
  State<_FocusTaskCard> createState() => _FocusTaskCardState();
}

class _FocusTaskCardState extends State<_FocusTaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
      reverseDuration: const Duration(milliseconds: 220),
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    final kc = context.kc;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = switch (widget.task.priority) {
      Priority.high   => const Color(0xFFF87171),
      Priority.medium => const Color(0xFFFB923C),
      Priority.low    => kc.text3,
    };

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/focus/timer?taskId=${widget.task.id}');
      },
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.055)
                    : Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Timer icon con acento de prioridad
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: kc.accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: kc.accent.withValues(alpha: 0.2)),
                    ),
                    child: Icon(Icons.timer_outlined, color: kc.accent, size: 17),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.task.title,
                            style: AppTypography.body13
                                .copyWith(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 10, color: kc.text3),
                            const SizedBox(width: 3),
                            Text('${widget.task.estimateMinutes}min',
                                style: AppTypography.mono11
                                    .copyWith(color: kc.text3)),
                            const SizedBox(width: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: priorityColor,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.task.priority == Priority.high
                                  ? 'Alta'
                                  : widget.task.priority == Priority.medium
                                      ? 'Media'
                                      : 'Baja',
                              style: AppTypography.mono11
                                  .copyWith(color: priorityColor, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kc.accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.play_arrow_rounded,
                        color: kc.accent, size: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(
      delay: Duration(milliseconds: 250 + widget.index * 60),
      duration: const Duration(milliseconds: 350),
    )
    .slideX(begin: -0.04, curve: Curves.easeOut);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: AppTypography.heading18.copyWith(
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: AppTypography.mono11.copyWith(color: kc.text3)),
      ],
    );
  }
}
