import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_shapes.dart';

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
    final radius = borderRadius ?? BorderRadius.circular(AppShapes.roundedSm);
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? kc.bg2,
        borderRadius: radius,
        border: border ?? Border.all(color: kc.line),
      ),
      child: child,
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final radius = borderRadius ?? BorderRadius.circular(AppShapes.roundedSm);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0x0FFFFFFF),
            borderRadius: radius,
            border: Border.all(color: kc.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
