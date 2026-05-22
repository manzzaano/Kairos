import 'package:flutter/material.dart';
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
                icon: Icon(Icons.delete_outline,
                    color: kc.danger),
                onPressed: () {
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
                  Text(task.project.toUpperCase(),
                      style: AppTypography.mono11
                          .copyWith(color: kc.text3)),
                  const SizedBox(height: AppSpacing.md),
                  Text(task.title, style: AppTypography.heading28),
                  if (task.description != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(task.description!,
                        style: AppTypography.body14
                            .copyWith(color: kc.text2)),
                  ],
                  const SizedBox(height: AppSpacing.xxl),

                  Container(
                    decoration: BoxDecoration(
                      color: kc.bg2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kc.line),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Prioridad', child: PriorityChip(priority: task.priority)),
                        Divider(color: kc.line, height: 1),
                        _InfoRow(label: 'Energía', child: EnergyDots(level: task.energyLevel)),
                        Divider(color: kc.line, height: 1),
                        _InfoRow(label: 'Estimación', child: Text('${task.estimateMinutes} min',
                            style: AppTypography.caption12.copyWith(color: kc.text2))),
                        if (task.dueLabel != null) ...[
                          Divider(color: kc.line, height: 1),
                          _InfoRow(label: 'Fecha', child: Text(task.dueLabel!,
                              style: AppTypography.caption12.copyWith(color: kc.text2))),
                        ],
                        Divider(color: kc.line, height: 1),
                        _InfoRow(label: 'Almacenamiento', child: Text('LOCAL',
                            style: AppTypography.mono11.copyWith(color: kc.text3))),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
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
                            borderRadius:
                                BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context
                          .push('/focus/timer?taskId=${task.id}'),
                      icon: Icon(Icons.timer_outlined,
                          color: kc.text),
                      label: Text('Iniciar Modo Enfoque',
                          style: AppTypography.body14),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kc.line2),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
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
