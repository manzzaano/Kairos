import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';

class KairosBackground extends StatelessWidget {
  final Widget child;
  final bool withGlows;

  const KairosBackground({
    required this.child,
    this.withGlows = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    if (!withGlows) {
      return ColoredBox(color: kc.bg, child: child);
    }
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: kc.bg),
          Positioned(
            top: -120,
            left: -120,
            width: 480,
            height: 480,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kc.glowCool, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            width: 480,
            height: 480,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kc.glowWarm, Colors.transparent],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
