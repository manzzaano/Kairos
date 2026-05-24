import 'package:flutter/widgets.dart';

/// Utility de responsividad para KAIROS.
/// Uso: KScreen.hPad(context) → padding horizontal adaptativo.
/// Breakpoints:
///   small  < 400px  → compacto (phone pequeño)
///   normal < 600px  → estándar (phone)
///   tablet ≥ 600px  → tablet / plegable abierto
///   large  ≥ 840px  → desktop / tablet grande
abstract final class KScreen {
  /// Ancho lógico de la pantalla.
  static double width(BuildContext ctx) => MediaQuery.sizeOf(ctx).width;

  // ── Breakpoints ─────────────────────────────────────────────────────────
  static bool isSmall(BuildContext ctx) => width(ctx) < 400;
  static bool isPhone(BuildContext ctx) => width(ctx) < 600;
  static bool isTablet(BuildContext ctx) => width(ctx) >= 600;
  static bool isLarge(BuildContext ctx) => width(ctx) >= 840;

  // ── Padding horizontal ───────────────────────────────────────────────────
  /// Padding horizontal principal de pantalla.
  static double hPad(BuildContext ctx) {
    final w = width(ctx);
    if (w >= 840) return (w - 760) / 2; // centrado, max 760 content
    if (w >= 600) return 32;
    if (w >= 400) return 20;
    return 16;
  }

  /// EdgeInsets con hPad horizontal y 0 vertical.
  static EdgeInsets hInsets(BuildContext ctx) =>
      EdgeInsets.symmetric(horizontal: hPad(ctx));

  // ── Columnas de grid ─────────────────────────────────────────────────────
  /// Columnas para el grid de KPI en Stats.
  static int statsColumns(BuildContext ctx) => isTablet(ctx) ? 4 : 2;

  /// Columnas para grids de tarjetas generales.
  static int cardColumns(BuildContext ctx) {
    if (isLarge(ctx)) return 3;
    if (isTablet(ctx)) return 2;
    return 1;
  }

  // ── Tamaño de fuente adaptativo ──────────────────────────────────────────
  /// Factor de escala de texto (1.0 phone, 1.05 tablet, 1.10 large).
  static double textScale(BuildContext ctx) {
    if (isLarge(ctx)) return 1.10;
    if (isTablet(ctx)) return 1.05;
    return 1.0;
  }

  // ── Top padding ──────────────────────────────────────────────────────────
  /// Padding superior para contenido bajo la status bar.
  static double topPad(BuildContext ctx) =>
      MediaQuery.paddingOf(ctx).top + 56;

  // ── Bottom padding ───────────────────────────────────────────────────────
  /// Altura del navbar flotante de KAIROS (aprox.).
  static const double _kNavBarHeight = 88.0;

  /// Padding inferior para contenido bajo navbar flotante + system nav bar.
  /// Evita que el contenido quede tapado por la barra de gestos Android.
  static double bottomPad(BuildContext ctx) =>
      MediaQuery.paddingOf(ctx).bottom + _kNavBarHeight + 16;
}
