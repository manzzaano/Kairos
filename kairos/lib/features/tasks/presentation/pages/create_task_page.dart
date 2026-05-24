import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});
  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _subtaskCtrl = TextEditingController();
  Priority _priority = Priority.medium;
  int _energy = 3;
  String? _dueLabel = 'Hoy';
  String _project = 'Personal';
  bool _showTitleError = false;
  final List<String> _subtasks = [];

  static const _energyLabels = [
    '', 'Mínima', 'Ligera', 'Media', 'Alta', 'Extrema'
  ];
  static const _dueDates = ['Hoy', 'Mañana', 'Esta semana', 'Sin fecha'];
  static const _projects = ['Personal', 'KAIROS', 'Académico', 'Code Review'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _subtaskCtrl.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _subtasks.add(text);
      _subtaskCtrl.clear();
    });
  }

  void _removeSubtask(int index) {
    HapticFeedback.lightImpact();
    setState(() => _subtasks.removeAt(index));
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      HapticFeedback.heavyImpact();
      setState(() => _showTitleError = true);
      return;
    }
    HapticFeedback.mediumImpact();
    context.read<TaskBloc>().add(CreateTaskRequested(TaskParams(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
      priority: _priority,
      energyLevel: _energy,
      dueLabel: _dueLabel,
      project: _project,
      subtasks: List.from(_subtasks),
    )));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final canSave = _titleCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: kc.bg,
      appBar: AppBar(
        backgroundColor: kc.bg,
        elevation: 0,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: Text('Cancelar',
              style: AppTypography.body13.copyWith(color: kc.text2)),
        ),
        leadingWidth: 90,
        title: Text('Nueva tarea', style: AppTypography.heading18),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: canSave ? _save : null,
            child: Text('Guardar',
                style: AppTypography.body13.copyWith(
                    color: canSave ? kc.accent : kc.text4,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              onChanged: (_) => setState(() => _showTitleError = false),
              style: AppTypography.heading22
                  .copyWith(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: '¿Qué tienes en mente?',
                hintStyle: AppTypography.heading22.copyWith(
                    color: kc.text3, fontWeight: FontWeight.w500),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8),
                errorText:
                    _showTitleError ? 'El título es obligatorio' : null,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Descripción
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              style: AppTypography.body13,
              decoration: InputDecoration(
                hintText: 'Descripción (opcional)',
                hintStyle:
                    AppTypography.body13.copyWith(color: kc.text3),
                filled: true,
                fillColor: kc.bg2,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kc.line)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kc.line)),
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Prioridad
            Text('Prioridad',
                style:
                    AppTypography.caption12.copyWith(color: kc.text2)),
            const SizedBox(height: AppSpacing.sm),
            _PrioritySegment(
              value: _priority,
              onChanged: (p) {
                HapticFeedback.selectionClick();
                setState(() => _priority = p);
              },
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Energía
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Energía requerida',
                    style: AppTypography.caption12
                        .copyWith(color: kc.text2)),
                Text('E$_energy · ${_energyLabels[_energy]}',
                    style:
                        AppTypography.mono11.copyWith(color: kc.accent)),
              ],
            ),
            Slider(
              value: _energy.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: kc.accent,
              inactiveColor: kc.bg3,
              onChanged: (v) => setState(() => _energy = v.toInt()),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Fecha
            Text('Fecha',
                style:
                    AppTypography.caption12.copyWith(color: kc.text2)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              children: _dueDates.map((d) {
                final selected =
                    _dueLabel == (d == 'Sin fecha' ? null : d);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() =>
                        _dueLabel = d == 'Sin fecha' ? null : d);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? kc.accentSoft : kc.bg2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: selected ? kc.accent : kc.line),
                    ),
                    child: Text(d,
                        style: AppTypography.caption12.copyWith(
                            color:
                                selected ? kc.accent : kc.text2)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Proyecto
            Text('Proyecto',
                style:
                    AppTypography.caption12.copyWith(color: kc.text2)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _projects.map((p) {
                final selected = _project == p;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _project = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? kc.accentSoft : kc.bg2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: selected ? kc.accent : kc.line),
                    ),
                    child: Text(p,
                        style: AppTypography.caption12.copyWith(
                            color: selected ? kc.accent : kc.text2)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Subtareas
            Row(
              children: [
                Text('Subtareas',
                    style: AppTypography.caption12
                        .copyWith(color: kc.text2)),
                if (_subtasks.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text('${_subtasks.length}',
                      style: AppTypography.mono11
                          .copyWith(color: kc.accent)),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Subtask list
            if (_subtasks.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: kc.bg2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kc.line),
                ),
                child: Column(
                  children: List.generate(_subtasks.length, (i) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.drag_handle,
                                  color: kc.text4, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_subtasks[i],
                                    style: AppTypography.body13),
                              ),
                              GestureDetector(
                                onTap: () => _removeSubtask(i),
                                child: Icon(Icons.close,
                                    color: kc.text3, size: 16),
                              ),
                            ],
                          ),
                        ),
                        if (i < _subtasks.length - 1)
                          Divider(color: kc.line, height: 1),
                      ],
                    );
                  }),
                ),
              ),
            // Add subtask input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskCtrl,
                    style: AppTypography.body13,
                    onSubmitted: (_) => _addSubtask(),
                    decoration: InputDecoration(
                      hintText: 'Añadir subtarea...',
                      hintStyle: AppTypography.body13
                          .copyWith(color: kc.text3),
                      filled: true,
                      fillColor: kc.bg2,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: kc.line)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: kc.line)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addSubtask,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kc.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.add,
                        color: const Color(0xFF1A0A00), size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                  color: kc.bg2,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.storage_outlined,
                      color: kc.text3, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Se guarda en local (Realm). Sin conexión requerida.',
                          style: AppTypography.mono11
                              .copyWith(color: kc.text3))),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSave ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kc.accent,
                  disabledBackgroundColor:
                      kc.accent.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Guardar',
                    style: AppTypography.body15
                        .copyWith(color: kc.bg)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrioritySegment extends StatelessWidget {
  final Priority value;
  final ValueChanged<Priority> onChanged;
  const _PrioritySegment({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Container(
      decoration: BoxDecoration(
        color: kc.bg2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kc.line),
      ),
      child: Row(
        children: Priority.values.map((p) {
          final selected = p == value;
          final color = p == Priority.high
              ? kc.danger
              : p == Priority.medium
                  ? kc.accent
                  : kc.text3;
          final label = p == Priority.high
              ? 'Alta'
              : p == Priority.medium
                  ? 'Media'
                  : 'Baja';
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: const EdgeInsets.all(3),
                padding:
                    const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: selected
                      ? Border.all(
                          color: color.withValues(alpha: 0.4))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? color
                            : color.withValues(alpha: 0.35),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: AppTypography.body13.copyWith(
                        color: selected ? color : kc.text2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
