import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/habit.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/k_screen.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  List<Habit> _habits = [];
  bool _loaded = false;

  static const _prefsKey = 'kairos_habits_v1';

  static const _emojiOptions = [
    '💪', '📚', '🧘', '💧', '🏃', '🥗', '😴', '✍️',
    '🎯', '🧠', '🎨', '🎸', '🌿', '🚴', '☀️', '🍎',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((j) => Habit.fromJson(j as Map<String, dynamic>))
            .toList();
        setState(() => _habits = list);
      } catch (_) {
        // Datos corruptos — se ignoran y se parte de lista vacía
      }
    }
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode(_habits.map((h) => h.toJson()).toList()));
  }

  Future<void> _toggleToday(Habit habit) async {
    HapticFeedback.selectionClick();
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final wasCompleted = habit.completedToday;
    final newCompletions = wasCompleted
        ? habit.completions.where((d) {
            final dOnly = DateTime(d.year, d.month, d.day);
            return dOnly != today;
          }).toList()
        : [...habit.completions, today];
    final updated = habit.copyWith(completions: newCompletions);
    setState(() {
      _habits =
          _habits.map((h) => h.id == habit.id ? updated : h).toList();
    });
    await _save();
  }

  Future<void> _deleteHabit(Habit habit) async {
    HapticFeedback.heavyImpact();
    setState(() => _habits.removeWhere((h) => h.id == habit.id));
    await _save();
  }

  void _showAddHabitSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddHabitSheet(
        emojiOptions: _emojiOptions,
        onAdd: (habit) async {
          setState(() => _habits.add(habit));
          await _save();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final todayDone = _habits.where((h) => h.completedToday).length;
    final total = _habits.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HÁBITOS DIARIOS',
                            style: AppTypography.mono11
                                .copyWith(color: kc.accent)),
                        const SizedBox(height: 4),
                        Text('Mis hábitos',
                            style: AppTypography.heading28),
                        if (total > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '$todayDone/$total completados hoy',
                            style: AppTypography.body13
                                .copyWith(color: kc.text2),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showAddHabitSheet,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kc.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add,
                          color: Color(0xFF1A0A00), size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar global
            if (total > 0) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: todayDone / total,
                    backgroundColor: kc.bg3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(kc.accent),
                    minHeight: 6,
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Habit list
            Expanded(
              child: !_loaded
                  ? Center(
                      child: CircularProgressIndicator(
                          color: kc.accent))
                  : _habits.isEmpty
                      ? _EmptyState(onAdd: _showAddHabitSheet)
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                              AppSpacing.xl, 0,
                              AppSpacing.xl, KScreen.bottomPad(context)),
                          itemCount: _habits.length,
                          itemBuilder: (ctx, i) => _HabitCard(
                            key: ValueKey(_habits[i].id),
                            habit: _habits[i],
                            onToggle: () => _toggleToday(_habits[i]),
                            onDelete: () => _deleteHabit(_habits[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const _HabitCard({
    required this.habit,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final done = habit.completedToday;

    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            color: kc.danger,
            borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child:
            const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return true;
      },
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: done
                ? kc.accent.withValues(alpha: 0.12)
                : kc.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: done ? kc.accent.withValues(alpha: 0.4) : kc.line,
            ),
          ),
          child: Row(
            children: [
              // Emoji
              Text(habit.emoji,
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: AppTypography.body14.copyWith(
                        fontWeight: FontWeight.w500,
                        decoration: done
                            ? TextDecoration.lineThrough
                            : null,
                        color: done ? kc.text3 : kc.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (habit.streak > 0) ...[
                          Icon(Icons.local_fire_department,
                              size: 12,
                              color: habit.streak >= 7
                                  ? const Color(0xFFF97316)
                                  : kc.text3),
                          const SizedBox(width: 3),
                          Text(
                            '${habit.streak} días',
                            style: AppTypography.mono11.copyWith(
                              color: habit.streak >= 7
                                  ? const Color(0xFFF97316)
                                  : kc.text3,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          '${habit.totalDone} completados',
                          style: AppTypography.mono11
                              .copyWith(color: kc.text3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Check circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? kc.accent : Colors.transparent,
                  border: Border.all(
                    color: done ? kc.accent : kc.line2,
                    width: 1.5,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check,
                        size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('Sin hábitos todavía',
              style: AppTypography.body14
                  .copyWith(color: kc.text2)),
          const SizedBox(height: 6),
          Text('Crea tu primer hábito para empezar',
              style: AppTypography.caption12
                  .copyWith(color: kc.text3)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: kc.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('+ Añadir hábito',
                  style: AppTypography.body13.copyWith(
                      color: const Color(0xFF1A0A00),
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddHabitSheet extends StatefulWidget {
  final List<String> emojiOptions;
  final Future<void> Function(Habit) onAdd;
  const _AddHabitSheet(
      {required this.emojiOptions, required this.onAdd});

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _ctrl = TextEditingController();
  String _emoji = '💪';
  HabitFrequency _freq = HabitFrequency.daily;
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _ctrl.text.trim(),
      emoji: _emoji,
      frequency: _freq,
    );
    await widget.onAdd(habit);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kc.bg2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kc.line2,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text('Nuevo hábito',
                    style: AppTypography.heading18),
              ),
              const SizedBox(height: 16),

              // Emoji picker
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Icono',
                    style: AppTypography.caption12
                        .copyWith(color: kc.text2)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  itemCount: widget.emojiOptions.length,
                  itemBuilder: (_, i) {
                    final e = widget.emojiOptions[i];
                    final selected = _emoji == e;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _emoji = e);
                      },
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? kc.accent.withValues(alpha: 0.15)
                              : kc.bg3,
                          borderRadius:
                              BorderRadius.circular(10),
                          border: selected
                              ? Border.all(
                                  color: kc.accent
                                      .withValues(alpha: 0.5))
                              : null,
                        ),
                        child: Center(
                          child: Text(e,
                              style:
                                  const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  style: AppTypography.body14,
                  decoration: InputDecoration(
                    hintText: 'Nombre del hábito...',
                    hintStyle: AppTypography.body14
                        .copyWith(color: kc.text3),
                    filled: true,
                    fillColor: kc.bg3,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Frequency
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Frecuencia',
                    style: AppTypography.caption12
                        .copyWith(color: kc.text2)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
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
                          duration:
                              const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(
                              right: f != HabitFrequency.weekly
                                  ? 8
                                  : 0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10),
                          decoration: BoxDecoration(
                            color: sel
                                ? kc.accent.withValues(alpha: 0.15)
                                : kc.bg3,
                            borderRadius:
                                BorderRadius.circular(10),
                            border: sel
                                ? Border.all(
                                    color: kc.accent
                                        .withValues(alpha: 0.5))
                                : null,
                          ),
                          child: Center(
                            child: Text(label,
                                style:
                                    AppTypography.caption12.copyWith(
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
              ),
              const SizedBox(height: 20),

              // CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kc.accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Añadir hábito',
                        style: AppTypography.body14.copyWith(
                            color: const Color(0xFF1A0A00),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
