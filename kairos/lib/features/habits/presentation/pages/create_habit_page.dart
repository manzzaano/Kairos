import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/habit.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';

class CreateHabitPage extends StatefulWidget {
  const CreateHabitPage({super.key});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final _ctrl = TextEditingController();
  String _icon = 'exercise';
  HabitFrequency _freq = HabitFrequency.daily;
  bool _saving = false;

  static const _prefsKey = 'kairos_habits_v1';

  static const _iconOptions = [
    'exercise', 'book', 'meditation', 'water', 'run', 'food',
    'sleep', 'write', 'target', 'brain', 'art', 'music',
    'nature', 'bike', 'sun', 'health',
  ];

  static const _iconLabels = {
    'exercise': 'Ejercicio',
    'book': 'Leer',
    'meditation': 'Meditación',
    'water': 'Agua',
    'run': 'Correr',
    'food': 'Nutrición',
    'sleep': 'Dormir',
    'write': 'Escribir',
    'target': 'Objetivo',
    'brain': 'Aprender',
    'art': 'Arte',
    'music': 'Música',
    'nature': 'Naturaleza',
    'bike': 'Ciclismo',
    'sun': 'Mañana',
    'health': 'Salud',
  };

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);

    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      emoji: _icon, // campo reutilizado para guardar clave de icono SVG
      frequency: _freq,
    );

    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    List<dynamic> list = [];
    if (raw != null) {
      try {
        list = jsonDecode(raw) as List<dynamic>;
      } catch (_) {}
    }
    list.add(habit.toJson());
    await prefs.setString(_prefsKey, jsonEncode(list));

    if (mounted) context.pop(habit);
  }

  Widget _buildIconGrid(KairosColors kc) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _iconOptions.length,
      itemBuilder: (_, i) {
        final key = _iconOptions[i];
        final selected = _icon == key;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _icon = key);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected ? kc.accentSoft : kc.bg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? kc.accent : kc.line,
                width: selected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/habits/$key.svg',
                  width: 26,
                  height: 26,
                  colorFilter: ColorFilter.mode(
                    selected ? kc.accent : kc.text3,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _iconLabels[key] ?? key,
                  style: AppTypography.mono11.copyWith(
                    fontSize: 8,
                    color: selected ? kc.accent : kc.text3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final canSave = _ctrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: kc.bg,
      appBar: AppBar(
        backgroundColor: kc.bg,
        elevation: 0,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: Text('Cancelar',
              style: AppTypography.body13.copyWith(color: kc.text2)),
        ),
        leadingWidth: 90,
        title: Text('Nuevo hábito', style: AppTypography.heading18),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: (canSave && !_saving) ? _submit : null,
            child: _saving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: kc.accent),
                  )
                : Text('Guardar',
                    style: AppTypography.body13.copyWith(
                        color: canSave ? kc.accent : kc.text4,
                        fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del hábito
            TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              style: AppTypography.heading22.copyWith(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: '¿Qué hábito quieres crear?',
                hintStyle: AppTypography.heading22.copyWith(
                    color: kc.text3, fontWeight: FontWeight.w500),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Selector de ícono
            Text('Ícono',
                style: AppTypography.caption12.copyWith(color: kc.text2)),
            const SizedBox(height: AppSpacing.md),
            _buildIconGrid(kc),
            const SizedBox(height: AppSpacing.xxl),

            // Frecuencia
            Text('Frecuencia',
                style: AppTypography.caption12.copyWith(color: kc.text2)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: HabitFrequency.values.map((f) {
                final label = f == HabitFrequency.daily
                    ? 'Diario'
                    : f == HabitFrequency.weekdays
                        ? 'L–V'
                        : 'Semanal';
                final sel = _freq == f;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _freq = f);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(
                          right: f != HabitFrequency.weekly ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? kc.accentSoft : kc.bg2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? kc.accent : kc.line,
                          width: sel ? 1.5 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(label,
                            style: AppTypography.body13.copyWith(
                              color: sel ? kc.accent : kc.text2,
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Preview del hábito
            if (canSave) ...[
              Text('Vista previa',
                  style: AppTypography.caption12.copyWith(color: kc.text2)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kc.bg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kc.line),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/habits/$_icon.svg',
                      width: 28,
                      height: 28,
                      colorFilter:
                          ColorFilter.mode(kc.accent, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(_ctrl.text.trim(),
                          style: AppTypography.body14.copyWith(
                              fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kc.line2, width: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (canSave && !_saving) ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kc.accent,
                  disabledBackgroundColor: kc.accent.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Añadir hábito',
                    style: AppTypography.body15.copyWith(color: kc.bg)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
