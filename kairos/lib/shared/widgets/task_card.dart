import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_shapes.dart';
import '../../features/tasks/domain/entities/task.dart';
import 'priority_chip.dart';
import 'energy_dots.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  const TaskCard({
    required this.task,
    this.onTap,
    this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Semantics(
      label: 'Tarea: ${task.title}, ${task.isDone ? "completada" : "pendiente"}',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kc.bg2,
            borderRadius: BorderRadius.circular(AppShapes.roundedSm),
            border: Border.all(color: kc.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: task.isDone
                    ? 'Marcar como pendiente'
                    : 'Marcar como completada',
                button: true,
                child: GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: task.isDone ? kc.accent : kc.line2,
                        width: 1.5,
                      ),
                      color: task.isDone ? kc.accent : Colors.transparent,
                    ),
                    child: task.isDone
                        ? const Icon(Icons.check,
                            size: 12, color: Color(0xFF1A0A00))
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTypography.body14.copyWith(
                        fontWeight: FontWeight.w500,
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? kc.text3 : kc.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PriorityChip(priority: task.priority),
                        EnergyDots(level: task.energyLevel),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, size: 11, color: kc.text3),
                            const SizedBox(width: 4),
                            Text(
                              '${task.estimateMinutes}m',
                              style: AppTypography.mono11
                                  .copyWith(color: kc.text3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
