import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_shapes.dart';

/// Tarjeta con efecto cristal translúcido.
/// Requiere contenido DETRÁS (gradiente de fondo) para que BackdropFilter tenga efecto.
/// dark:  white 7% + blur 22 → cristal oscuro sutil
/// light: white 72% + blur 22 → cristal claro estilo iOS
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;

  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.margin,
    this.blurSigma = 22,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(AppShapes.roundedSm);

    // Colores adaptativos
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.white.withValues(alpha: 0.72);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.80);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.30)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: radius,
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                if (isDark)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.04),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Tarjeta sólida — usa glass sutil cuando hay fondo gradient detrás,
/// o un color sólido opaco cuando se necesita contraste garantizado.
/// Por defecto usa glass (BackdropFilter) igual que GlassCard pero con
/// opacidad mayor para mejor legibilidad en contenido denso.
class SolidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Border? border;

  const SolidCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.margin,
    this.backgroundColor,
    this.border,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(AppShapes.roundedSm);

    if (backgroundColor != null) {
      // Color explícito → sólido sin blur
      return Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: radius,
          border: border ?? Border.all(color: kc.line),
        ),
        child: child,
      );
    }

    // Sin color explícito → glass ligeramente más opaco que GlassCard
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.80);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.09)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: radius,
              border: border ?? Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: isDark ? 0.20 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
