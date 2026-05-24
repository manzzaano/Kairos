import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_shapes.dart';
import '../../features/tasks/domain/entities/task.dart';
import 'priority_chip.dart';
import 'energy_dots.dart';

class TaskCard extends StatefulWidget {
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
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0,
      upperBound: 1,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) => _pressCtrl.reverse();
  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label:
          'Tarea: ${widget.task.title}, ${widget.task.isDone ? "completada" : "pendiente"}',
      button: widget.onTap != null,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap?.call();
          },
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kc.bg2,
              borderRadius: BorderRadius.circular(AppShapes.roundedSm),
              border: Border.all(color: kc.line),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: widget.task.isDone
                      ? 'Marcar como pendiente'
                      : 'Marcar como completada',
                  button: true,
                  child: _AnimatedCheckbox(
                    checked: widget.task.isDone,
                    accent: kc.accent,
                    borderColor: widget.task.isDone ? kc.accent : kc.line2,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onToggle?.call();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTypography.body14.copyWith(
                          fontWeight: FontWeight.w500,
                          decoration: widget.task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: widget.task.isDone ? kc.text3 : kc.text,
                        ),
                        child: Text(
                          widget.task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          PriorityChip(priority: widget.task.priority),
                          EnergyDots(level: widget.task.energyLevel),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule,
                                  size: 11, color: kc.text3),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.task.estimateMinutes}m',
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
      ),
    );
  }
}

/// Checkbox con spring animation en el check mark.
class _AnimatedCheckbox extends StatefulWidget {
  final bool checked;
  final Color accent;
  final Color borderColor;
  final VoidCallback? onTap;

  const _AnimatedCheckbox({
    required this.checked,
    required this.accent,
    required this.borderColor,
    this.onTap,
  });

  @override
  State<_AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<_AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: widget.checked ? 1.0 : 0.0,
    );
    _scale = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void didUpdateWidget(_AnimatedCheckbox old) {
    super.didUpdateWidget(old);
    if (widget.checked != old.checked) {
      if (widget.checked) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: widget.borderColor,
            width: 1.5,
          ),
          color: widget.checked ? widget.accent : Colors.transparent,
        ),
        child: ScaleTransition(
          scale: _scale,
          child: const Icon(Icons.check, size: 12, color: Color(0xFF1A0A00)),
        ),
      ),
    );
  }
}
