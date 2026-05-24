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
import '../../../../core/constants/app_shapes.dart';
import '../../../../shared/widgets/fab_kairos.dart';
import '../../../../shared/widgets/task_card.dart';
import '../../../../core/utils/k_screen.dart';

enum _Filter { all, today, pending, done, high }

enum _Sort { date, priority, energy }

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});
  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  _Filter _filter = _Filter.all;
  _Sort _sort = _Sort.date;
  String _search = '';
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasksRequested());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Task> _filtered(List<Task> tasks) {
    var r = tasks.toList();

    // Search
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      r = r
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              (t.description?.toLowerCase().contains(q) ?? false) ||
              t.project.toLowerCase().contains(q))
          .toList();
    }

    // Category filter
    switch (_filter) {
      case _Filter.today:
        r = r.where((t) => !t.isDone && t.dueLabel == 'Hoy').toList();
        break;
      case _Filter.pending:
        r = r.where((t) => !t.isDone).toList();
        break;
      case _Filter.done:
        r = r.where((t) => t.isDone).toList();
        break;
      case _Filter.high:
        r = r.where((t) => t.priority == Priority.high).toList();
        break;
      case _Filter.all:
        break;
    }

    // Sort
    switch (_sort) {
      case _Sort.priority:
        r.sort((a, b) => a.priority.index.compareTo(b.priority.index));
        break;
      case _Sort.energy:
        r.sort((a, b) => b.energyLevel.compareTo(a.energyLevel));
        break;
      case _Sort.date:
        break;
    }

    return r;
  }

  void _showSortSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final kc = context.kc;
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kc.bg2,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: kc.line2,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Ordenar por',
                    style: AppTypography.heading18),
              ),
              const SizedBox(height: 12),
              ...[
                (_Sort.date, 'Fecha de creación', Icons.calendar_today_outlined),
                (_Sort.priority, 'Prioridad (alta primero)', Icons.flag_outlined),
                (_Sort.energy, 'Energía (mayor primero)', Icons.bolt_outlined),
              ].map((item) {
                final (sort, label, icon) = item;
                final selected = _sort == sort;
                return ListTile(
                  leading: Icon(icon,
                      color: selected ? kc.accent : kc.text2,
                      size: 20),
                  title: Text(label,
                      style: AppTypography.body13.copyWith(
                          color: selected ? kc.accent : kc.text,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400)),
                  trailing: selected
                      ? Icon(Icons.check, color: kc.accent, size: 18)
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _sort = sort);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              final tasks = state is TaskLoaded
                  ? _filtered(state.tasks)
                  : <Task>[];
              final total =
                  state is TaskLoaded ? state.tasks.length : 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        KScreen.hPad(context), KScreen.topPad(context),
                        KScreen.hPad(context), 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row + sort + search toggle
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Todas las tareas',
                                      style: AppTypography.heading28),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$total en total · desliza para acción rápida',
                                    style: AppTypography.body13
                                        .copyWith(color: kc.text2),
                                  ),
                                ],
                              ),
                            ),
                            // Sort button
                            GestureDetector(
                              onTap: _showSortSheet,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _sort != _Sort.date
                                      ? kc.accentSoft
                                      : kc.bg2,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                      color: _sort != _Sort.date
                                          ? kc.accent
                                          : kc.line),
                                ),
                                child: Icon(Icons.sort,
                                    color: _sort != _Sort.date
                                        ? kc.accent
                                        : kc.text2,
                                    size: 18),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Search toggle
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _showSearch = !_showSearch;
                                  if (!_showSearch) {
                                    _search = '';
                                    _searchCtrl.clear();
                                  }
                                });
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _showSearch
                                      ? kc.accentSoft
                                      : kc.bg2,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                      color: _showSearch
                                          ? kc.accent
                                          : kc.line),
                                ),
                                child: Icon(Icons.search,
                                    color: _showSearch
                                        ? kc.accent
                                        : kc.text2,
                                    size: 18),
                              ),
                            ),
                          ],
                        ),

                        // Search bar — animated
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          child: _showSearch
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: AppSpacing.md),
                                  child: TextField(
                                    controller: _searchCtrl,
                                    autofocus: true,
                                    style: AppTypography.body13,
                                    onChanged: (v) =>
                                        setState(() => _search = v),
                                    decoration: InputDecoration(
                                      hintText: 'Buscar tareas...',
                                      hintStyle: AppTypography.body13
                                          .copyWith(color: kc.text3),
                                      prefixIcon: Icon(Icons.search,
                                          color: kc.text3, size: 18),
                                      suffixIcon: _search.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () => setState(() {
                                                _search = '';
                                                _searchCtrl.clear();
                                              }),
                                              child: Icon(Icons.close,
                                                  color: kc.text3,
                                                  size: 16),
                                            )
                                          : null,
                                      filled: true,
                                      fillColor: kc.bg2,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide:
                                              BorderSide(color: kc.line)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide:
                                              BorderSide(color: kc.line)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: kc.accent)),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Filter chips
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
                                  label: 'Hoy',
                                  active: _filter == _Filter.today,
                                  onTap: () => setState(
                                      () => _filter = _Filter.today)),
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
                              Icon(
                                _search.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.check_circle_outline,
                                color: kc.text3,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _search.isNotEmpty
                                    ? 'Sin resultados para "$_search"'
                                    : _filter == _Filter.all
                                        ? 'Crea tu primera tarea'
                                        : 'No hay tareas en esta categoría',
                                style: AppTypography.body14
                                    .copyWith(color: kc.text2),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _search.isNotEmpty
                                    ? 'Prueba con otras palabras'
                                    : _filter == _Filter.all
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
      padding: EdgeInsets.symmetric(horizontal: KScreen.hPad(context)),
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
      onUpdate: (details) {
        if (details.reached && !details.previousReached) {
          HapticFeedback.mediumImpact();
        }
      },
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          HapticFeedback.selectionClick();
          context.read<TaskBloc>().add(ToggleTaskRequested(id: task.id));
          return false;
        } else {
          HapticFeedback.heavyImpact();
          context.read<TaskBloc>().add(DeleteTaskRequested(id: task.id));
          return true;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TaskCard(
          task: task,
          onTap: () => context.push('/task/${task.id}'),
          onToggle: () =>
              context.read<TaskBloc>().add(ToggleTaskRequested(id: task.id)),
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
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kc.text : kc.bg2,
          borderRadius: BorderRadius.circular(AppShapes.pill),
          border: active ? null : Border.all(color: kc.line),
        ),
        child: Text(label,
            style: AppTypography.caption12.copyWith(
                color: active ? kc.bg : kc.text2,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}
