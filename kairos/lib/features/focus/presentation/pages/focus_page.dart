import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _FocusPageState extends State<FocusPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasksRequested());
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          final allTasks = state is TaskLoaded ? state.tasks : <Task>[];
          final pending = allTasks.where((t) => !t.isDone).take(4).toList();

          final completedToday = allTasks.where((t) => t.isDone).length;
          final totalTimeMinutes = allTasks
              .where((t) => t.isDone)
              .fold<int>(0, (sum, t) => sum + t.estimateMinutes);
          final hours = totalTimeMinutes ~/ 60;
          final mins = totalTimeMinutes % 60;
          final timeLabel = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                KScreen.hPad(context), KScreen.topPad(context),
                KScreen.hPad(context), AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DEEP WORK',
                    style: AppTypography.mono11.copyWith(color: kc.accent)),
                const SizedBox(height: AppSpacing.md),
                Text('Modo enfoque', style: AppTypography.heading28),
                const SizedBox(height: AppSpacing.sm),
                Text(
                    'Una tarea. Un cronómetro. Sin distracciones.',
                    style: AppTypography.body14.copyWith(color: kc.text2)),
                const SizedBox(height: AppSpacing.xxl),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.push('/focus/timer');
                    },
                    icon: const Icon(Icons.play_arrow,
                        color: Color(0xFF1A0A00), size: 18),
                    label: Text('Empezar sesión libre',
                        style: AppTypography.body15.copyWith(
                            color: const Color(0xFF1A0A00),
                            fontWeight: FontWeight.w500)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kc.accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                if (pending.isNotEmpty) ...[
                  Row(children: [
                    Expanded(child: Divider(color: kc.line)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: Text('O ENFÓCATE EN UNA TAREA',
                          style: AppTypography.mono11
                              .copyWith(color: kc.text3)),
                    ),
                    Expanded(child: Divider(color: kc.line)),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  for (final task in pending) _FocusTaskCard(task: task),
                ],

                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: kc.bg2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kc.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HOY',
                          style: AppTypography.mono11
                              .copyWith(color: kc.text3)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _StatItem(label: 'Sesiones', value: '${pending.length}'),
                          const SizedBox(width: AppSpacing.xxl),
                          _StatItem(label: 'Tiempo', value: timeLabel),
                          const SizedBox(width: AppSpacing.xxl),
                          _StatItem(label: 'Completadas', value: '$completedToday'),
                        ],
                      ),
                    ],
                  ),
                ),

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
  const _FocusTaskCard({required this.task});

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
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: kc.bg2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kc.line),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kc.bg3,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.timer_outlined, color: kc.text3, size: 16),
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
                    const SizedBox(height: 2),
                    Text(
                        '${widget.task.estimateMinutes}min · E${widget.task.energyLevel}',
                        style: AppTypography.mono11
                            .copyWith(color: kc.text3)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: kc.text3, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: AppTypography.heading18
                .copyWith(fontWeight: FontWeight.w600)),
        Text(label,
            style: AppTypography.mono11.copyWith(color: kc.text3)),
      ],
    );
  }
}
