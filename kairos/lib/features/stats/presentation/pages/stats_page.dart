import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../habits/presentation/pages/habits_page.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/k_screen.dart';

/// Wrapper que contiene Stats y Hábitos en dos pestañas.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 52),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.07),
                      ),
                    ),
                    child: TabBar(
                      labelColor: kc.accent,
                      unselectedLabelColor: kc.text3,
                      indicatorColor: kc.accent,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.transparent,
                      labelStyle: AppTypography.body13.copyWith(
                          fontWeight: FontWeight.w600),
                      unselectedLabelStyle: AppTypography.body13,
                      tabs: const [
                        Tab(text: 'Estadísticas'),
                        Tab(text: 'Hábitos'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Expanded(
              child: TabBarView(
                children: [
                  _StatsBody(),
                  HabitsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBody extends StatefulWidget {
  const _StatsBody();

  @override
  State<_StatsBody> createState() => _StatsBodyState();
}

class _StatsBodyState extends State<_StatsBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _barCtrl;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  static DateTime _dayOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static List<int> _weekBars(List<Task> tasks) {
    final today = _dayOnly(DateTime.now());
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return tasks
          .where((t) =>
              t.completedAt != null &&
              _dayOnly(t.completedAt!) == day)
          .length;
    });
  }

  static List<int> _heatmapData(List<Task> tasks) {
    final today = _dayOnly(DateTime.now());
    return List.generate(28, (i) {
      final day = today.subtract(Duration(days: 27 - i));
      return tasks
          .where((t) =>
              t.completedAt != null &&
              _dayOnly(t.completedAt!) == day)
          .length;
    });
  }

  static int _streak(List<Task> tasks) {
    int count = 0;
    DateTime check = _dayOnly(DateTime.now());
    while (true) {
      final hasAny = tasks.any(
          (t) => t.completedAt != null && _dayOnly(t.completedAt!) == check);
      if (!hasAny) break;
      count++;
      check = check.subtract(const Duration(days: 1));
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        final tasks =
            state is TaskLoaded ? state.tasks : <Task>[];
        final done = tasks.where((t) => t.isDone).toList();
        final pending = tasks.where((t) => !t.isDone).toList();
        final totalFocusMin = done
            .fold<int>(0, (s, t) => s + t.estimateMinutes);
        final hours = totalFocusMin ~/ 60;
        final mins = totalFocusMin % 60;
        final bars = _weekBars(tasks);
        final streak = _streak(tasks);
        final weekDone = bars.fold<int>(0, (a, b) => a + b);
        final dailyAvg = weekDone > 0
            ? (weekDone / 7).toStringAsFixed(1)
            : '0.0';

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              KScreen.hPad(context), AppSpacing.lg,
              KScreen.hPad(context), AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [kc.accent, kc.accent.withValues(alpha: 0.3)],
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ÚLTIMOS 7 DÍAS',
                          style: AppTypography.mono11
                              .copyWith(color: kc.text3)),
                      const SizedBox(height: 2),
                      Text('Tu productividad',
                          style: AppTypography.heading28),
                    ],
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.1, curve: Curves.easeOut),
              const SizedBox(height: AppSpacing.xxl),

              // KPI grid
              GridView.count(
                crossAxisCount: KScreen.statsColumns(context),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.35,
                children: [
                  _KpiCard(
                    label: 'Completadas',
                    value: '${done.length}',
                    sub: '$weekDone esta semana',
                    color: kc.success,
                    icon: Icons.check_circle_outline_rounded,
                    index: 0,
                  ),
                  _KpiCard(
                    label: 'Tiempo enfocado',
                    value: '${hours}h ${mins}m',
                    sub: '${done.length} completadas',
                    color: kc.accent,
                    icon: Icons.timer_outlined,
                    index: 1,
                  ),
                  _KpiCard(
                    label: 'Racha actual',
                    value: '$streak días',
                    sub: streak > 0 ? '¡Sigue así!' : 'Completa hoy',
                    color: kc.warning,
                    icon: Icons.local_fire_department_outlined,
                    index: 2,
                  ),
                  _KpiCard(
                    label: 'Tareas/día',
                    value: dailyAvg,
                    sub: 'media semanal',
                    color: kc.accent2,
                    icon: Icons.bar_chart_rounded,
                    index: 3,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Bar chart
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            size: 14, color: kc.accent),
                        const SizedBox(width: 6),
                        Text('COMPLETADAS POR DÍA',
                            style: AppTypography.mono11
                                .copyWith(color: kc.text3)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _BarChart(bars: bars, barCtrl: _barCtrl),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.08, curve: Curves.easeOut),
              const SizedBox(height: AppSpacing.xxl),

              // Heatmap
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.grid_view_rounded,
                            size: 14, color: kc.accent),
                        const SizedBox(width: 6),
                        Text('ACTIVIDAD — 4 SEMANAS',
                            style: AppTypography.mono11
                                .copyWith(color: kc.text3)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Heatmap(data: _heatmapData(tasks)),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.08, curve: Curves.easeOut),
              const SizedBox(height: AppSpacing.xxl),

              // Insights header
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 14, color: kc.accent),
                  const SizedBox(width: 6),
                  Text('INSIGHTS',
                      style: AppTypography.mono11.copyWith(color: kc.text3)),
                ],
              )
              .animate()
              .fadeIn(delay: 500.ms),
              const SizedBox(height: AppSpacing.md),

              if (pending.isEmpty && done.isNotEmpty)
                const _InsightCard(
                    icon: Icons.celebration_outlined,
                    text: '¡Todas tus tareas están completadas! Crea nuevas tareas.'),
              if (pending.isNotEmpty)
                _InsightCard(
                    icon: Icons.pending_actions_outlined,
                    text:
                        'Tienes ${pending.length} tarea${pending.length != 1 ? "s" : ""} pendiente${pending.length != 1 ? "s" : ""}.'),
              if (done.any((t) => t.priority == Priority.high))
                _InsightCard(
                    icon: Icons.flag_outlined,
                    text:
                        'Has completado ${done.where((t) => t.priority == Priority.high).length} tarea${done.where((t) => t.priority == Priority.high).length != 1 ? "s" : ""} de alta prioridad.'),
              if (streak >= 2)
                _InsightCard(
                    icon: Icons.local_fire_department_outlined,
                    text:
                        'Llevas $streak días consecutivos completando tareas. ¡Sigue así!'),
              if (tasks.isEmpty)
                const _InsightCard(
                    icon: Icons.add_task_rounded,
                    text: 'Crea tu primera tarea para ver estadísticas reales.'),

              SizedBox(height: KScreen.bottomPad(context)),
            ],
          ),
        );
      },
    );
  }
}

/// Tarjeta glass reutilizable (BackdropFilter + borde sutil)
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.055)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;
  final int index;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.055)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border(
              top: BorderSide(color: color.withValues(alpha: 0.60), width: 2),
              left: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
              ),
              right: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
              ),
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: AppTypography.caption12.copyWith(color: kc.text3)),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 13, color: color),
                  ),
                ],
              ),
              Text(value,
                  style: AppTypography.mono22.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  )),
              Text(sub,
                  style: AppTypography.mono11.copyWith(color: kc.text3)),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(
      delay: Duration(milliseconds: 100 + index * 80),
      duration: const Duration(milliseconds: 400),
    )
    .slideY(
      begin: 0.15,
      curve: Curves.easeOut,
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<int> bars;
  final AnimationController barCtrl;
  const _BarChart({required this.bars, required this.barCtrl});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final max = bars.isEmpty
        ? 1
        : bars.reduce((a, b) => a > b ? a : b).clamp(1, 999);
    final today = DateTime.now().weekday - 1;

    return AnimatedBuilder(
      animation: barCtrl,
      builder: (context, _) {
        final t = CurvedAnimation(
          parent: barCtrl,
          curve: Curves.easeOutCubic,
        ).value;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final rawH = (bars[i] / max * 80).clamp(4.0, 80.0);
            final h = rawH * t;
            final isToday = i == today;
            final hasValue = bars[i] > 0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasValue && isToday)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${bars[i]}',
                      style: AppTypography.mono11.copyWith(
                        color: kc.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                Container(
                  width: 28,
                  height: h.clamp(4.0, 80.0),
                  decoration: BoxDecoration(
                    gradient: isToday
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              kc.accent,
                              kc.accent.withValues(alpha: 0.6),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.10),
                              isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.05),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: kc.accent.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(days[i],
                    style: AppTypography.mono11.copyWith(
                        color: isToday ? kc.accent : kc.text3,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
              ],
            );
          }),
        );
      },
    );
  }
}

class _Heatmap extends StatelessWidget {
  final List<int> data; // 28 values
  const _Heatmap({required this.data});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxVal = data.isEmpty
        ? 1
        : data.reduce((a, b) => a > b ? a : b).clamp(1, 999);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cellSize =
                ((constraints.maxWidth / 28) - 4).clamp(6.0, 14.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (w) {
                return Row(
                  children: List.generate(7, (d) {
                    final idx = w * 7 + d;
                    final val = idx < data.length ? data[idx] : 0;
                    final level =
                        maxVal > 0 ? (val / maxVal).clamp(0.0, 1.0) : 0.0;
                    Color cellColor;
                    if (val == 0) {
                      cellColor = isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.06);
                    } else if (level <= 0.25) {
                      cellColor = kc.accent.withValues(alpha: 0.20);
                    } else if (level <= 0.50) {
                      cellColor = kc.accent.withValues(alpha: 0.40);
                    } else if (level <= 0.75) {
                      cellColor = kc.accent.withValues(alpha: 0.65);
                    } else {
                      cellColor = kc.accent.withValues(alpha: 0.95);
                    }
                    final isToday = idx == 27;
                    return Container(
                      width: cellSize,
                      height: cellSize,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(3),
                        border: isToday
                            ? Border.all(
                                color: kc.accent.withValues(alpha: 0.7),
                                width: 1,
                              )
                            : null,
                        boxShadow: val > 0 && level > 0.5
                            ? [
                                BoxShadow(
                                  color: kc.accent.withValues(alpha: 0.20),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('MENOS',
                style: AppTypography.mono11.copyWith(color: kc.text4, fontSize: 9)),
            const SizedBox(width: 6),
            ...List.generate(5, (i) {
              const opacities = [0.06, 0.20, 0.40, 0.65, 0.95];
              final alpha = opacities[i];
              final legendColor = i == 0
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: alpha)
                      : Colors.black.withValues(alpha: alpha))
                  : kc.accent.withValues(alpha: alpha);
              return Container(
                width: 11,
                height: 11,
                margin: const EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                  color: legendColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
            const SizedBox(width: 6),
            Text('MÁS',
                style: AppTypography.mono11.copyWith(color: kc.text4, fontSize: 9)),
          ],
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String text;
  final IconData icon;
  const _InsightCard({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: kc.accent.withValues(alpha: 0.5), width: 2),
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                ),
                right: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                ),
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kc.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: kc.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(text,
                      style: AppTypography.body13.copyWith(color: kc.text2)),
                ),
              ],
            ),
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 350.ms)
    .slideX(begin: -0.04, curve: Curves.easeOut);
  }
}
