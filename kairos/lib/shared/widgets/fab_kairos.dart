import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_shapes.dart';

class FABKairos extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  const FABKairos({required this.onPressed, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Semantics(
      label: 'Crear nueva tarea',
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: kc.accent,
            borderRadius: BorderRadius.circular(AppShapes.fabRadius),
            boxShadow: [
              BoxShadow(
                color: kc.accent.withValues(alpha: 0.35),
                blurRadius: 30,
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
            icon,
            color: const Color(0xFF1A0A00),
            size: 26,
          ),
        ),
      ),
    );
  }
}
