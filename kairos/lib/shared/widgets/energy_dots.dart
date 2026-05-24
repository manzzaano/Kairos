import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';

class EnergyDots extends StatelessWidget {
  final int level; // 1-5
  const EnergyDots({required this.level, super.key});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < level ? kc.accent : kc.line2,
          ),
        ),
      ),
    );
  }
}
