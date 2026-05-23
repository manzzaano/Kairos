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
import '../../../../core/constants/app_shapes.dart';
import '../../../../shared/widgets/fab_kairos.dart';
import '../../../../shared/widgets/task_card.dart';

enum _Filter { all, pending, done, high }

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});
  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasksRequested());
  }

  List<Task> _filtered(List<Task> tasks) {
    switch (_filter) {
      case _Filter.pending:
        return tasks.where((t) => !t.isDone).toList();
      case _Filter.done:
        return tasks.where((t) => t.isDone).toList();
      case _Filter.high:
        return tasks.where((t) => t.priority == Priority.high).toList();
      case _Filter.all:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: kc.bg,
      body: Stack(
        children: [
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              final tasks =
                  state is TaskLoaded ? _filtered(state.tasks) : <Task>[];
              final total =
                  state is TaskLoaded ? state.tasks.length : 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, 64, AppSpacing.xl, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Todas las tareas',
                            style: AppTypography.heading28),
                        const SizedBox(height: 4),
                        Text(
                            '$total en total · desliza para acción rápida',
                            style: AppTypography.body13
                                .copyWith(color: kc.text2)),
                        const SizedBox(height: AppSpacing.lg),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                  label: 'Todas',
                                  active: _filter == _Filter.all,
                                  onTap: () => setState(
                                      () => _filter = _Filter.all)),
                              const SizedBox(width: 8),
                              _FilterChip(
                                  label: 'Pendientes',
                                  active: _filter == _Filter.pending,
                                  onTap: () => setState(
                                      () => _filter = _Filter.pending)),
                              const SizedBox(width: 8),
                              _FilterChip(
                                  label: 'Completadas',
                                  active: _filter == _Filter.done,
                                  onTap: () => setState(
                                      () => _filter = _Filter.done)),
                              const SizedBox(width: 8),
                              _FilterChip(
                                  label: 'Alta prioridad',
                                  active: _filter == _Filter.high,
                                  onTap: () => setState(
                                      () => _filter = _Filter.high)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (state is TaskLoading)
                    Expanded(
                        child: Center(
                            child: CircularProgressIndicator(
                                color: kc.accent)))
                  else if (tasks.isEmpty)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: kc.text3, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                _filter == _Filter.all
                                    ? 'Crea tu primera tarea'
                                    : 'No hay tareas en esta categoría',
                                style: AppTypography.body14
                                    .copyWith(color: kc.text2),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _filter == _Filter.all
                                    ? 'Toca + para empezar'
                                    : 'Cambia el filtro para ver otras',
                                style: AppTypography.caption12
                                    .copyWith(color: kc.text3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: _GroupedTaskList(tasks: tasks),
                    ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: FABKairos(
              onPressed: () => context.push('/create-task'),
              icon: Icons.add,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupedTaskList extends StatelessWidget {
  final List<Task> tasks;
  const _GroupedTaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final groups = <String, List<Task>>{};
    for (final t in tasks) {
      groups.putIfAbsent(t.project, () => []).add(t);
    }

    return ListView(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(
                top: AppSpacing.lg, bottom: AppSpacing.sm),
            child: Row(
              children: [
                Text(entry.key.toUpperCase(),
                    style: AppTypography.mono11
                        .copyWith(color: kc.text3)),
                const SizedBox(width: 8),
                Text('${entry.value.length}',
                    style: AppTypography.mono11
                        .copyWith(color: kc.text4)),
              ],
            ),
          ),
          for (final task in entry.value)
            _SwipeableTaskRow(key: ValueKey(task.id), task: task),
        ],
        const SizedBox(height: 100),
      ],
    );
  }
}

class _SwipeableTaskRow extends StatelessWidget {
  final Task task;
  const _SwipeableTaskRow({required this.task, super.key});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            color: kc.success,
            borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            color: kc.danger,
            borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          context.read<TaskBloc>().add(ToggleTaskRequested(id: task.id));
          return false;
        } else {
          context.read<TaskBloc>().add(DeleteTaskRequested(id: task.id));
          return true;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TaskCard(
          task: task,
          onTap: () => context.push('/task/${task.id}'),
          onToggle: () => context.read<TaskBloc>().add(ToggleTaskRequested(id: task.id)),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kc.text : kc.bg2,
          borderRadius: BorderRadius.circular(AppShapes.pill),
          border: active ? null : Border.all(color: kc.line),
        ),
        child: Text(label,
            style: AppTypography.caption12.copyWith(
                color: active ? kc.bg : kc.text2)),
      ),
    );
  }
}
