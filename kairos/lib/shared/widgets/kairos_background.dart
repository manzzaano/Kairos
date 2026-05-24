import 'package:flutter/material.dart';

/// Fondo global de KAIROS.
/// Gradiente sutil dark/light — sin blobs animados.
/// Las tarjetas GlassCard sobre este fondo crean el efecto translúcido
/// via BackdropFilter (difuminan el gradiente que hay detrás).
class KairosBackground extends StatelessWidget {
  final Widget child;

  // [withGlows] mantenido por compatibilidad de API — ya no hace nada.
  const KairosBackground({
    required this.child,
    // ignore: avoid_unused_constructor_parameters
    bool withGlows = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.55, 1.0],
                colors: [
                  Color(0xFF07070E), // azul-negro muy sutil
                  Color(0xFF050505), // negro puro
                  Color(0xFF0A080A), // ligeramente púrpura
                ],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0],
                colors: [
                  Color(0xFFF2F2F7), // Apple system background
                  Color(0xFFFFFFFF),
                ],
              ),
      ),
      child: child,
    );
  }
}
