import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/xp_calculator.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/task_card.dart';
import '../../../../shared/widgets/fab_kairos.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../core/utils/k_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasksRequested());
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 13) return 'Buenos días, Ismael';
    if (h < 20) return 'Buenas tardes, Ismael';
    return 'Buenas noches, Ismael';
  }

  String _dateLabel() {
    const days = [
      'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO', 'DOMINGO'
    ];
    const months = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE'
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} DE ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return Center(
                        child: CircularProgressIndicator(color: kc.accent));
                  }
                  if (state is TaskError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, color: kc.danger, size: 40),
                            const SizedBox(height: 12),
                            Text(state.message,
                                textAlign: TextAlign.center,
                                style: AppTypography.body13.copyWith(color: kc.text2)),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => context.read<TaskBloc>()
                                  .add(const LoadTasksRequested()),
                              child: Text('Reintentar',
                                  style: AppTypography.body13.copyWith(color: kc.accent)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final tasks =
                      state is TaskLoaded ? state.tasks : <Task>[];
                  final pending = tasks.where((t) => !t.isDone).toList();
                  final done = tasks.where((t) => t.isDone).toList();
                  final totalEnergy =
                      pending.fold<int>(0, (s, t) => s + t.energyLevel);
                  const maxEnergy = 18;

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              KScreen.hPad(context), KScreen.topPad(context),
                              KScreen.hPad(context), 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: date label top-left, bell icon top-right
                              Row(
                                children: [
                                  Text(_dateLabel(),
                                      style: AppTypography.mono11
                                          .copyWith(color: kc.text3)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Sin notificaciones nuevas'),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: kc.bg2,
                                        border: Border.all(color: kc.line),
                                      ),
                                      child: Icon(Icons.notifications_outlined,
                                          color: kc.text2, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Greeting below date
                              Text(_greeting(),
                                  style: AppTypography.heading28),
                              const SizedBox(height: 6),
                              // XP badge inline
                              Builder(builder: (ctx) {
                                final xp = XpCalculator.totalXp(tasks);
                                final lvl = XpCalculator.level(xp);
                                final lvlName = XpCalculator.levelName(lvl);
                                return Row(
                                  children: [
                                    Icon(Icons.bolt,
                                        color: kc.accent, size: 13),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Nivel $lvl · $lvlName · $xp XP',
                                      style: AppTypography.mono11
                                          .copyWith(color: kc.accent),
                                    ),
                                  ],
                                );
                              }),
                              const SizedBox(height: AppSpacing.xxl),

                              // Energy card — SolidCard with radius 14
                              SolidCard(
                                padding: const EdgeInsets.all(16),
                                borderRadius: BorderRadius.circular(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Energía requerida hoy',
                                        style: AppTypography.caption12
                                            .copyWith(color: kc.text2)),
                                    const SizedBox(height: AppSpacing.md),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(99),
                                      child: SizedBox(
                                        height: 6,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ColoredBox(color: kc.bg3),
                                            FractionallySizedBox(
                                              widthFactor: maxEnergy > 0
                                                  ? (totalEnergy / maxEnergy).clamp(0.0, 1.0)
                                                  : 0.0,
                                              alignment: Alignment.centerLeft,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [kc.glowCool, kc.glowWarm],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    // Footer: single row, no fraction display
                                    Text(
                                        '${pending.length} pendientes · ${done.length} completadas',
                                        style: AppTypography.mono11
                                            .copyWith(color: kc.text3)),
                                  ],
                                ),
                              ),

                              // AI Optimize CTA
                              const SizedBox(height: AppSpacing.md),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.push('/optimize');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0x24FB923C),
                                        Color(0x0AFB923C)
                                      ],
                                    ),
                                    border: Border.all(
                                        color: const Color(0x40FB923C)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: const Color(0x1FFB923C),
                                        ),
                                        child: const Icon(Icons.auto_awesome,
                                            color: Color(0xFFFB923C),
                                            size: 16),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Optimizar mi día con IA',
                                                style: AppTypography.body14
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w500)),
                                            Text(
                                                'Reordena por prioridad y energía',
                                                style: AppTypography.caption12
                                                    .copyWith(
                                                        color: kc.text3)),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right,
                                          color: kc.text3, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                            ],
                          ),
                        ),
                      ),

                      // Pending section header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsets.fromLTRB(KScreen.hPad(context), AppSpacing.md, KScreen.hPad(context), AppSpacing.sm),
                          child: Row(
                            children: [
                              Text('PENDIENTES',
                                  style: AppTypography.mono11
                                      .copyWith(color: kc.text3)),
                              const SizedBox(width: AppSpacing.sm),
                              Text('${pending.length}',
                                  style: AppTypography.mono11
                                      .copyWith(color: kc.text3)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => context.go('/tasks'),
                                child: Text('Ver todas',
                                    style: AppTypography.caption12
                                        .copyWith(color: kc.accent)),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (pending.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xxxl),
                            child: Center(
                              child: Text('No hay tareas pendientes',
                                  style: AppTypography.body13
                                      .copyWith(color: kc.text3)),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                              if (i >= pending.length.clamp(0, 4)) return null;
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: KScreen.hPad(ctx), vertical: AppSpacing.xs),
                                child: TaskCard(
                                  task: pending[i],
                                  onTap: () =>
                                      context.push('/task/${pending[i].id}'),
                                  onToggle: () =>
                                      context.read<TaskBloc>().add(
                                          ToggleTaskRequested(
                                              id: pending[i].id)),
                                ),
                              );
                            },
                            childCount: pending.length.clamp(0, 4),
                          ),
                        ),

                      if (done.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                EdgeInsets.fromLTRB(KScreen.hPad(context), AppSpacing.xxl, KScreen.hPad(context), AppSpacing.sm),
                            child: Row(
                              children: [
                                Text('COMPLETADAS',
                                    style: AppTypography.mono11
                                        .copyWith(color: kc.text3)),
                                const SizedBox(width: AppSpacing.sm),
                                Text('${done.length}',
                                    style: AppTypography.mono11
                                        .copyWith(color: kc.text3)),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
                              child: Opacity(
                                opacity: 0.5,
                                child: TaskCard(
                                  task: done[i],
                                  onTap: () =>
                                      context.push('/task/${done[i].id}'),
                                  onToggle: () =>
                                      context.read<TaskBloc>().add(
                                          ToggleTaskRequested(
                                              id: done[i].id)),
                                ),
                              ),
                            ),
                            childCount: done.length.clamp(0, 2),
                          ),
                        ),
                      ],

                      SliverToBoxAdapter(
                          child: SizedBox(height: KScreen.bottomPad(context))),
                    ],
                  );
                },
              ),
          Positioned(
            bottom: KScreen.bottomPad(context) - 40,
            right: 20,
            child: FABKairos(
              onPressed: () => context.push('/create-task'),
              icon: Icons.add,
            ),
          ),
        ],
      ),
    );
  }
}
