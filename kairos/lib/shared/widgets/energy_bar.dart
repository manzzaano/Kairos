import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';

class EnergyBar extends StatelessWidget {
  final int level; // 1-5
  const EnergyBar({required this.level, super.key});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final fill = (level / 5).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 6,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: kc.bg3),
            FractionallySizedBox(
              widthFactor: fill,
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kc.glowCool, kc.glowWarm],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
