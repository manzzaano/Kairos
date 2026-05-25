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

  Future<void> _openCreateHabitPage() async {
    HapticFeedback.lightImpact();
    final result = await context.push<Habit>('/create-habit');
    // El hábito ya fue guardado en SharedPreferences por CreateHabitPage
    // Solo recargamos la lista para reflejar el cambio
    if (result != null && mounted) {
      await _load();
    }
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
                    onTap: _openCreateHabitPage,
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
                      ? _EmptyState(onAdd: _openCreateHabitPage)
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
  // Claves SVG válidas (mismo set que _HabitsPageState)
  static const _knownIcons = {
    'exercise', 'book', 'meditation', 'water', 'run', 'food',
    'sleep', 'write', 'target', 'brain', 'art', 'music',
    'nature', 'bike', 'sun', 'health',
  };
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
              // Ícono SVG (o fallback si datos legacy con emoji)
              _knownIcons.contains(habit.emoji)
                  ? SvgPicture.asset(
                      'assets/icons/habits/${habit.emoji}.svg',
                      width: 28,
                      height: 28,
                      colorFilter: ColorFilter.mode(
                        done ? kc.accent : kc.text2,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(Icons.star_outline,
                      size: 28,
                      color: done ? kc.accent : kc.text2),
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
          SvgPicture.asset(
            'assets/icons/habits/nature.svg',
            width: 56,
            height: 56,
            colorFilter: ColorFilter.mode(kc.text3, BlendMode.srcIn),
          ),
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

