import 'package:flutter/material.dart';

/// Fondo global de KAIROS.
/// Dark: gradiente oscuro con tres paradas + orb de acento sutil arriba.
/// Light: gradiente Apple-style frío-blanco.
/// Las tarjetas GlassCard sobre este fondo crean el efecto translúcido
/// via BackdropFilter (difuminan el gradiente que hay detrás).
class KairosBackground extends StatelessWidget {
  final Widget child;

  const KairosBackground({
    required this.child,
    // ignore: avoid_unused_constructor_parameters
    bool withGlows = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Base gradient ─────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.5, 1.0],
                    colors: [
                      Color(0xFF07070F), // azul-negro
                      Color(0xFF050505), // negro puro
                      Color(0xFF0A0708), // ligeramente cálido
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 1.0],
                    colors: [
                      Color(0xFFF0F0F5), // Apple system background
                      Color(0xFFFFFFFF),
                    ],
                  ),
          ),
        ),

        // ── Orb de acento (top-right) ─────────────────────
        // Solo en dark mode, muy sutil, no distrae
        if (isDark)
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.07),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

        // ── Orb secundario (bottom-left) ─────────────────
        if (isDark)
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.04),
                    const Color(0xFF3B82F6).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

        child,
      ],
    );
  }
}
