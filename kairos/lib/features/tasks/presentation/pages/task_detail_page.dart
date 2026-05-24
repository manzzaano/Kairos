import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../domain/entities/task.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/priority_chip.dart';
import '../../../../shared/widgets/energy_dots.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;
  const TaskDetailPage({required this.taskId, super.key});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        final tasks =
            state is TaskLoaded ? state.tasks : <Task>[];
        final task =
            tasks.where((t) => t.id == taskId).firstOrNull;

        if (task == null) {
          return Scaffold(
            backgroundColor: kc.bg,
            appBar: AppBar(
                backgroundColor: kc.bg, elevation: 0),
            body: Center(
                child: Text('Tarea no encontrada',
                    style: AppTypography.body13
                        .copyWith(color: kc.text3))),
          );
        }

        final doneSubtasks =
            task.subtasksDone.where((d) => d).length;
        final totalSubtasks = task.subtasks.length;

        return Scaffold(
          backgroundColor: kc.bg,
          appBar: AppBar(
            backgroundColor: kc.bg,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kc.bg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kc.line),
                  ),
                  child: Icon(Icons.close, color: kc.text, size: 18),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.delete_outline, color: kc.danger),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  context
                      .read<TaskBloc>()
                      .add(DeleteTaskRequested(id: task.id));
                  context.pop();
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project + title
                  Text(task.project.toUpperCase(),
                      style: AppTypography.mono11
                          .copyWith(color: kc.text3)),
                  const SizedBox(height: AppSpacing.md),
                  Text(task.title,
                      style: AppTypography.heading28.copyWith(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isDone ? kc.text3 : kc.text,
                      )),
                  if (task.description != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(task.description!,
                        style: AppTypography.body14
                            .copyWith(color: kc.text2)),
                  ],
                  const SizedBox(height: AppSpacing.xxl),

                  // Subtasks checklist
                  if (task.subtasks.isNotEmpty) ...[
                    Row(
                      children: [
                        Text('SUBTAREAS',
                            style: AppTypography.mono11
                                .copyWith(color: kc.text3)),
                        const SizedBox(width: 8),
                        Text('$doneSubtasks/$totalSubtasks',
                            style: AppTypography.mono11
                                .copyWith(color: kc.accent)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: totalSubtasks > 0
                            ? doneSubtasks / totalSubtasks
                            : 0,
                        backgroundColor: kc.bg3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kc.accent),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      decoration: BoxDecoration(
                        color: kc.bg2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kc.line),
                      ),
                      child: Column(
                        children: List.generate(
                          task.subtasks.length,
                          (i) => _SubtaskRow(
                            key: ValueKey('${task.id}-sub-$i'),
                            label: task.subtasks[i],
                            done: task.subtasksDone.length > i
                                ? task.subtasksDone[i]
                                : false,
                            isLast: i == task.subtasks.length - 1,
                            onToggle: () {
                              HapticFeedback.selectionClick();
                              context.read<TaskBloc>().add(
                                  ToggleSubtaskRequested(
                                      taskId: task.id,
                                      subtaskIndex: i));
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // Info grid
                  Container(
                    decoration: BoxDecoration(
                      color: kc.bg2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kc.line),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                            label: 'Prioridad',
                            child: PriorityChip(priority: task.priority)),
                        Divider(color: kc.line, height: 1),
                        _InfoRow(
                            label: 'Energía',
                            child: EnergyDots(level: task.energyLevel)),
                        Divider(color: kc.line, height: 1),
                        _InfoRow(
                            label: 'Estimación',
                            child: Text('${task.estimateMinutes} min',
                                style: AppTypography.caption12
                                    .copyWith(color: kc.text2))),
                        if (task.dueLabel != null) ...[
                          Divider(color: kc.line, height: 1),
                          _InfoRow(
                              label: 'Fecha',
                              child: Text(task.dueLabel!,
                                  style: AppTypography.caption12
                                      .copyWith(color: kc.text2))),
                        ],
                        Divider(color: kc.line, height: 1),
                        _InfoRow(
                            label: 'Almacenamiento',
                            child: Text('LOCAL',
                                style: AppTypography.mono11
                                    .copyWith(color: kc.text3))),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        context.read<TaskBloc>().add(
                            ToggleTaskRequested(id: task.id));
                        context.pop();
                      },
                      icon: Icon(
                          task.isDone ? Icons.undo : Icons.check,
                          color: kc.bg),
                      label: Text(
                        task.isDone
                            ? 'Marcar como pendiente'
                            : 'Marcar como completada',
                        style: AppTypography.body14
                            .copyWith(color: kc.bg),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kc.accent,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push('/focus/timer?taskId=${task.id}');
                      },
                      icon: Icon(Icons.timer_outlined, color: kc.text),
                      label: Text('Iniciar Modo Enfoque',
                          style: AppTypography.body14),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kc.line2),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  final String label;
  final bool done;
  final bool isLast;
  final VoidCallback onToggle;
  const _SubtaskRow({
    required this.label,
    required this.done,
    required this.isLast,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? kc.accent : Colors.transparent,
                    border: Border.all(
                      color: done ? kc.accent : kc.line2,
                      width: 1.5,
                    ),
                  ),
                  child: done
                      ? const Icon(Icons.check,
                          size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTypography.body13.copyWith(
                      color: done ? kc.text3 : kc.text,
                      decoration:
                          done ? TextDecoration.lineThrough : null,
                    ),
                    child: Text(label, maxLines: 2),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(color: kc.line, height: 1),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _InfoRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.caption12
                  .copyWith(color: context.kc.text3)),
          child,
        ],
      ),
    );
  }
}
