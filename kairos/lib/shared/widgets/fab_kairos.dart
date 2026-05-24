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
    with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final AnimationController _glowCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
      reverseDuration: const Duration(milliseconds: 300),
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glow = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _glowCtrl.dispose();
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
          HapticFeedback.mediumImpact();
          widget.onPressed();
        },
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedBuilder(
            animation: _glow,
            builder: (_, child) {
              final g = _glow.value;
              return Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kc.accent,
                      kc.accent.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppShapes.fabRadius),
                  boxShadow: [
                    // Glow pulsante externo
                    BoxShadow(
                      color: kc.accent.withValues(alpha: 0.30 + g * 0.20),
                      blurRadius: 24 + g * 16,
                      spreadRadius: g * 2,
                      offset: const Offset(0, 8),
                    ),
                    // Sombra base
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Icon(
              widget.icon,
              color: Colors.black.withValues(alpha: 0.85),
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
