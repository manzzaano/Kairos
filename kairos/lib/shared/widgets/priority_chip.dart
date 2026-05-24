import 'package:flutter/material.dart';
import '../../features/tasks/domain/entities/task.dart';

class PriorityChip extends StatelessWidget {
  final Priority priority;
  const PriorityChip({required this.priority, super.key});

  static const _chipColors = {
    Priority.high: {
      'bg': Color(0x1FF87171),
      'fgDark': Color(0xFFFCA5A5),
      'fgLight': Color(0xFFB91C1C),
      'dot': Color(0xFFF87171),
      'label': 'Alta',
    },
    Priority.medium: {
      'bg': Color(0x1FFB923C),
      'fgDark': Color(0xFFFDBA74),
      'fgLight': Color(0xFFC2410C),
      'dot': Color(0xFFFB923C),
      'label': 'Media',
    },
    Priority.low: {
      'bg': Color(0x2E737373),
      'fgDark': Color(0xFFA3A3A3),
      'fgLight': Color(0xFF525252),
      'dot': Color(0xFF737373),
      'label': 'Baja',
    },
  };

  @override
  Widget build(BuildContext context) {
    final config = _chipColors[priority]!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? config['fgDark'] as Color : config['fgLight'] as Color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: config['dot'] as Color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            (config['label'] as String).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.22,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
