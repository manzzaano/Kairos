import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kairos/core/theme/theme_cubit.dart';

void main() {
  group('ThemeCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is dark + orange accent', () {
      final cubit = ThemeCubit();
      expect(cubit.state.mode, ThemeMode.dark);
      expect(cubit.state.accent, const Color(0xFFFB923C));
      cubit.close();
    });

    test('toggleMode switches dark → light', () async {
      final cubit = ThemeCubit();
      expect(cubit.state.mode, ThemeMode.dark);
      await cubit.toggleMode();
      expect(cubit.state.mode, ThemeMode.light);
      cubit.close();
    });

    test('toggleMode switches light → dark', () async {
      final cubit = ThemeCubit();
      await cubit.toggleMode(); // dark → light
      await cubit.toggleMode(); // light → dark
      expect(cubit.state.mode, ThemeMode.dark);
      cubit.close();
    });

    test('setAccent changes accent color', () async {
      final cubit = ThemeCubit();
      const newColor = Color(0xFF3B82F6); // blue
      await cubit.setAccent(newColor);
      expect(cubit.state.accent, newColor);
      cubit.close();
    });

    test('setAccent preserves theme mode', () async {
      final cubit = ThemeCubit();
      await cubit.toggleMode(); // dark → light
      await cubit.setAccent(const Color(0xFF10B981));
      expect(cubit.state.mode, ThemeMode.light);
      cubit.close();
    });

    test('load restores persisted state', () async {
      final cubit = ThemeCubit();
      await cubit.toggleMode(); // dark → light → persist
      await cubit.setAccent(const Color(0xFF8B5CF6)); // persist accent
      cubit.close();

      final cubit2 = ThemeCubit();
      await cubit2.load();
      expect(cubit2.state.mode, ThemeMode.light);
      expect(cubit2.state.accent, const Color(0xFF8B5CF6));
      cubit2.close();
    });
  });
}
