import 'package:flutter/material.dart';
import 'kairos_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_shapes.dart';

class AppTheme {
  static ThemeData dark(Color accent) =>
      _build(Brightness.dark, KairosColors.dark(accent));

  static ThemeData light(Color accent) =>
      _build(Brightness.light, KairosColors.light(accent));

  static ThemeData _build(Brightness brightness, KairosColors kc) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        scaffoldBackgroundColor: kc.bg,
        extensions: [kc],
        colorScheme: ColorScheme(
          brightness: brightness,
          primary: kc.accent,
          onPrimary: brightness == Brightness.dark
              ? const Color(0xFF1A0A00)
              : Colors.white,
          secondary: kc.accent2,
          onSecondary:
              brightness == Brightness.dark ? Colors.black : Colors.white,
          surface: kc.bg2,
          onSurface: kc.text,
          error: kc.danger,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: kc.text),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppShapes.btnRadius),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kc.bg2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppShapes.inputRadius),
            borderSide: BorderSide(color: kc.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppShapes.inputRadius),
            borderSide: BorderSide(color: kc.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppShapes.inputRadius),
            borderSide: BorderSide(color: kc.accent, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: AppTypography.body13.copyWith(color: kc.text3),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(kc.accent),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: kc.accent,
          inactiveTrackColor: kc.bg3,
          thumbColor: kc.accent,
          overlayColor: kc.accent.withValues(alpha: 0.12),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? kc.accent : kc.text3),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? kc.accentSoft : kc.bg3),
        ),
        dividerColor: kc.line,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          indicatorColor: kc.bg3,
          labelTextStyle: WidgetStateProperty.all(
            AppTypography.caption12.copyWith(color: kc.text),
          ),
        ),
      );
}
