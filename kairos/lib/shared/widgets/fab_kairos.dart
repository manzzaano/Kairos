import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_shapes.dart';

class FABKairos extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  const FABKairos({required this.onPressed, required this.icon, super.key});

  @override
  State<FABKairos> createState() => _FABKairosState();
}

class _FABKairosState extends State<FABKairos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
      reverseDuration: const Duration(milliseconds: 300),
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Semantics(
      label: 'Crear nueva tarea',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onPressed();
        },
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: kc.accent,
              borderRadius: BorderRadius.circular(AppShapes.fabRadius),
              boxShadow: [
                BoxShadow(
                  color: kc.accent.withValues(alpha: 0.40),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: kc.accent.withValues(alpha: 0.50),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: const Color(0xFF1A0A00),
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
