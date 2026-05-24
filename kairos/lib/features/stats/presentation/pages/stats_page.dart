import 'package:flutter/material.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 52),
            TabBar(
              labelColor: kc.accent,
              unselectedLabelColor: kc.text3,
              indicatorColor: kc.accent,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: AppTypography.body13.copyWith(
                  fontWeight: FontWeight.w600),
              unselectedLabelStyle: AppTypography.body13,
              tabs: const [
                Tab(text: 'Estadísticas'),
                Tab(text: 'Hábitos'),
              ],
            ),
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

class _StatsBody extends StatelessWidget {
  const _StatsBody();

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
          final weekDone =
              bars.fold<int>(0, (a, b) => a + b);
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
                Text('ÚLTIMOS 7 DÍAS',
                    style: AppTypography.mono11
                        .copyWith(color: kc.text3)),
                const SizedBox(height: AppSpacing.sm),
                Text('Tu productividad',
                    style: AppTypography.heading28),
                const SizedBox(height: AppSpacing.xxl),

                // KPI grid
                GridView.count(
                  crossAxisCount: KScreen.statsColumns(context),
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.4,
                  children: [
                    _KpiCard(
                        label: 'Completadas',
                        value: '${done.length}',
                        sub: '$weekDone esta semana',
                        color: kc.success),
                    _KpiCard(
                        label: 'Tiempo estimado',
                        value: '${hours}h ${mins}m',
                        sub: '${done.length} completadas',
                        color: kc.accent),
                    _KpiCard(
                        label: 'Racha actual',
                        value: '$streak días',
                        sub: streak > 0
                            ? '¡Sigue así!'
                            : 'Completa hoy',
                        color: kc.warning),
                    _KpiCard(
                        label: 'Tareas/día',
                        value: dailyAvg,
                        sub: 'media semanal',
                        color: kc.accent2),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Bar chart wrapped in card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kc.bg2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kc.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('COMPLETADAS POR DÍA',
                          style: AppTypography.mono11
                              .copyWith(color: kc.text3)),
                      const SizedBox(height: AppSpacing.lg),
                      _BarChart(bars: bars),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Heatmap wrapped in card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kc.bg2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kc.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACTIVIDAD — 4 SEMANAS',
                          style: AppTypography.mono11
                              .copyWith(color: kc.text3)),
                      const SizedBox(height: AppSpacing.lg),
                      _Heatmap(data: _heatmapData(tasks)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Insights (computed from real data)
                Text('INSIGHTS',
                    style: AppTypography.mono11
                        .copyWith(color: kc.text3)),
                const SizedBox(height: AppSpacing.md),
                if (pending.isEmpty && done.isNotEmpty)
                  _InsightCard(
                      text:
                          '¡Todas tus tareas están completadas! Crea nuevas tareas.')
                else if (pending.isNotEmpty)
                  _InsightCard(
                      text:
                          'Tienes ${pending.length} tarea${pending.length != 1 ? "s" : ""} pendiente${pending.length != 1 ? "s" : ""}.'),
                if (done.any((t) => t.priority == Priority.high))
                  _InsightCard(
                      text:
                          'Has completado ${done.where((t) => t.priority == Priority.high).length} tarea${done.where((t) => t.priority == Priority.high).length != 1 ? "s" : ""} de alta prioridad.'),
                if (streak >= 2)
                  _InsightCard(
                      text:
                          'Llevas $streak días consecutivos completando tareas. ¡Sigue así!'),
                if (tasks.isEmpty)
                  _InsightCard(
                      text:
                          'Crea tu primera tarea para ver estadísticas reales.'),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.sub,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kc.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kc.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.caption12
                  .copyWith(color: kc.text3)),
          Text(value,
              style:
                  AppTypography.mono22.copyWith(color: color)),
          Text(sub,
              style: AppTypography.mono11
                  .copyWith(color: kc.text3)),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<int> bars;
  const _BarChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final max = bars.isEmpty
        ? 1
        : bars.reduce((a, b) => a > b ? a : b).clamp(1, 999);
    final today = DateTime.now().weekday - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final h = (bars[i] / max * 80).clamp(4.0, 80.0);
        final isToday = i == today;
        return Column(
          children: [
            Container(
              width: 28,
              height: h,
              decoration: BoxDecoration(
                color: isToday ? kc.accent : kc.bg3,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(days[i],
                style: AppTypography.mono11.copyWith(
                    color: isToday ? kc.accent : kc.text3)),
          ],
        );
      }),
    );
  }
}

class _Heatmap extends StatelessWidget {
  final List<int> data; // 28 values
  const _Heatmap({required this.data});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
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
                    final level = maxVal > 0 ? (val / maxVal).clamp(0.0, 1.0) : 0.0;
                    Color cellColor;
                    if (val == 0) {
                      cellColor = const Color(0x0AFFFFFF);
                    } else if (level <= 0.25) {
                      cellColor = kc.accent.withValues(alpha: 0.20);
                    } else if (level <= 0.50) {
                      cellColor = kc.accent.withValues(alpha: 0.40);
                    } else if (level <= 0.75) {
                      cellColor = kc.accent.withValues(alpha: 0.65);
                    } else {
                      cellColor = kc.accent.withValues(alpha: 0.95);
                    }
                    return Container(
                      width: cellSize,
                      height: cellSize,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('MENOS',
                style: AppTypography.mono11
                    .copyWith(color: kc.text4)),
            const SizedBox(width: 8),
            ...List.generate(
                5,
                (i) {
                  const opacities = [0.20, 0.40, 0.65, 0.95];
                  final alpha = i == 0 ? 0.04 : opacities[i - 1];
                  final legendColor = i == 0
                      ? const Color(0x0AFFFFFF)
                      : kc.accent.withValues(alpha: alpha);
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 3),
                    decoration: BoxDecoration(
                      color: legendColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
            const SizedBox(width: 8),
            Text('MÁS',
                style: AppTypography.mono11
                    .copyWith(color: kc.text4)),
          ],
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String text;
  const _InsightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kc.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kc.line),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kc.accent,
            ),
          ),
          Expanded(
              child: Text(text,
                  style: AppTypography.body13
                      .copyWith(color: kc.text2))),
        ],
      ),
    );
  }
}
