import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode mode;
  final Color accent;
  const ThemeState({required this.mode, required this.accent});

  ThemeState copyWith({ThemeMode? mode, Color? accent}) =>
      ThemeState(mode: mode ?? this.mode, accent: accent ?? this.accent);
}

class ThemeCubit extends Cubit<ThemeState> {
  static const _modeKey = 'kairos_theme_mode';
  static const _accentKey = 'kairos_accent_color';

  ThemeCubit()
      : super(const ThemeState(
            mode: ThemeMode.dark, accent: Color(0xFFFB923C)));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIdx = prefs.getInt(_modeKey) ?? 2;
    final accentVal = prefs.getInt(_accentKey) ?? 0xFFFB923C;
    emit(ThemeState(
      mode: ThemeMode.values[modeIdx.clamp(0, 2)],
      accent: Color(accentVal),
    ));
  }

  Future<void> toggleMode() async {
    final newMode =
        state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, newMode.index);
    emit(state.copyWith(mode: newMode));
  }

  Future<void> setAccent(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    // ignore: deprecated_member_use
    await prefs.setInt(_accentKey, color.value);
    emit(state.copyWith(accent: color));
  }
}
