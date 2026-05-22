import 'package:flutter/material.dart';

@immutable
class KairosColors extends ThemeExtension<KairosColors> {
  final Color accent;
  final Color accent2;
  final Color accentSoft;
  final Color bg;
  final Color bg2;
  final Color bg3;
  final Color line;
  final Color line2;
  final Color text;
  final Color text2;
  final Color text3;
  final Color text4;
  final Color glowCool;
  final Color glowWarm;
  final Color success;
  final Color danger;
  final Color warning;

  const KairosColors({
    required this.accent,
    required this.accent2,
    required this.accentSoft,
    required this.bg,
    required this.bg2,
    required this.bg3,
    required this.line,
    required this.line2,
    required this.text,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.glowCool,
    required this.glowWarm,
    required this.success,
    required this.danger,
    required this.warning,
  });

  factory KairosColors.dark(Color accent) => KairosColors(
        accent: const Color(0xFFF0E6D7),     // warm ivory (diseño_nuevo)
        accent2: const Color(0xFFFDBA74),    // #fdba74
        accentSoft: const Color(0x26F0E6D7), // rgba(240,230,215,0.15)
        bg: const Color(0xFF050505),         // #050505 (diseño_nuevo)
        bg2: const Color(0xFF161616),        // #161616 SOLID
        bg3: const Color(0xFF1C1C1C),        // #1c1c1c SOLID
        line: const Color(0x26FFFFFF),        // rgba(255,255,255,0.15) — theme.json
        line2: const Color(0x1AFFFFFF),       // rgba(255,255,255,0.10)
        text: const Color(0xFFFAFAFA),
        text2: const Color(0xFFA3A3A3),
        text3: const Color(0xFF525252),
        text4: const Color(0xFF404040),
        glowCool: const Color(0x80A0B9D2),   // rgba(160,185,210,0.5) theme.json
        glowWarm: const Color(0x80F0E6D7),   // rgba(240,230,215,0.5) theme.json
        success: const Color(0xFFA8D5B0),    // desaturated mint
        danger: const Color(0xFFE8A4A4),     // desaturated rose
        warning: const Color(0xFFE8D896),    // desaturated yellow
      );

  factory KairosColors.light(Color accent) => KairosColors(
        accent: accent,
        accent2: const Color(0xFF8A7060),
        accentSoft: accent.withValues(alpha: 0.12),
        bg: const Color(0xFFFAFAFA),
        bg2: const Color(0xB3FFFFFF),
        bg3: const Color(0x80FFFFFF),
        line: const Color(0x14000000),
        line2: const Color(0x40000000),
        text: const Color(0xFF0A0A0A),
        text2: const Color(0xFF525252),
        text3: const Color(0xFF909090),
        text4: const Color(0xFFBBBBBB),
        glowCool: const Color(0x40A0B9D2),
        glowWarm: const Color(0x40F0E6D7),
        success: const Color(0xFF16A34A),
        danger: const Color(0xFFDC2626),
        warning: const Color(0xFFD97706),
      );

  static KairosColors of(BuildContext context) =>
      Theme.of(context).extension<KairosColors>()!;

  @override
  KairosColors copyWith({
    Color? accent,
    Color? accent2,
    Color? accentSoft,
    Color? bg,
    Color? bg2,
    Color? bg3,
    Color? line,
    Color? line2,
    Color? text,
    Color? text2,
    Color? text3,
    Color? text4,
    Color? glowCool,
    Color? glowWarm,
    Color? success,
    Color? danger,
    Color? warning,
  }) =>
      KairosColors(
        accent: accent ?? this.accent,
        accent2: accent2 ?? this.accent2,
        accentSoft: accentSoft ?? this.accentSoft,
        bg: bg ?? this.bg,
        bg2: bg2 ?? this.bg2,
        bg3: bg3 ?? this.bg3,
        line: line ?? this.line,
        line2: line2 ?? this.line2,
        text: text ?? this.text,
        text2: text2 ?? this.text2,
        text3: text3 ?? this.text3,
        text4: text4 ?? this.text4,
        glowCool: glowCool ?? this.glowCool,
        glowWarm: glowWarm ?? this.glowWarm,
        success: success ?? this.success,
        danger: danger ?? this.danger,
        warning: warning ?? this.warning,
      );

  @override
  KairosColors lerp(KairosColors? other, double t) {
    if (other is! KairosColors) return this;
    return KairosColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accent2: Color.lerp(accent2, other.accent2, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      bg3: Color.lerp(bg3, other.bg3, t)!,
      line: Color.lerp(line, other.line, t)!,
      line2: Color.lerp(line2, other.line2, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      text4: Color.lerp(text4, other.text4, t)!,
      glowCool: Color.lerp(glowCool, other.glowCool, t)!,
      glowWarm: Color.lerp(glowWarm, other.glowWarm, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension KairosThemeX on BuildContext {
  KairosColors get kc => KairosColors.of(this);
}
