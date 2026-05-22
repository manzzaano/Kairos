import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/core/theme/kairos_colors.dart';

void main() {
  group('KairosColors.dark', () {
    late KairosColors kc;
    setUp(() => kc = KairosColors.dark(const Color(0xFFFB923C)));

    test('bg is #050505', () => expect(kc.bg, const Color(0xFF050505)));
    test('bg2 is #161616 solid', () => expect(kc.bg2, const Color(0xFF161616)));
    test('bg3 is #1C1C1C solid', () => expect(kc.bg3, const Color(0xFF1C1C1C)));
    test('line is rgba(255,255,255,0.06)', () => expect(kc.line, const Color(0x0FFFFFFF)));
    test('line2 is rgba(255,255,255,0.10)', () => expect(kc.line2, const Color(0x1AFFFFFF)));
    test('accent is #FB923C orange', () => expect(kc.accent, const Color(0xFFFB923C)));
    test('glowCool is rgba(160,185,210,0.5)', () => expect(kc.glowCool, const Color(0x80A0B9D2)));
    test('glowWarm is rgba(240,230,215,0.5)', () => expect(kc.glowWarm, const Color(0x80F0E6D7)));
  });

  group('KairosColors.light', () {
    late KairosColors kc;
    setUp(() => kc = KairosColors.light(const Color(0xFF5A7A9A)));

    test('bg is #FAFAFA', () => expect(kc.bg, const Color(0xFFFAFAFA)));
    test('bg2 is frosted 70%', () => expect(kc.bg2, const Color(0xB3FFFFFF)));
    test('glowCool light is 25%', () => expect(kc.glowCool, const Color(0x40A0B9D2)));
    test('glowWarm light is 25%', () => expect(kc.glowWarm, const Color(0x40F0E6D7)));
  });

  group('KairosColors copyWith preserves glowCool/glowWarm', () {
    test('copyWith returns updated glowCool', () {
      final kc = KairosColors.dark(const Color(0xFFFB923C));
      final updated = kc.copyWith(glowCool: Colors.red);
      expect(updated.glowCool, Colors.red);
      expect(updated.bg, kc.bg);
    });
  });
}
