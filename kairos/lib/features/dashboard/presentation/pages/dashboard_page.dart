import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../../../../core/utils/k_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitCtrl;
  String _displayName = '';

  static const _nameKey = 'kairos_display_name';

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasksRequested());
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey) ?? '';
    if (mounted) setState(() => _displayName = name);
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final name = () {
      if (_displayName.isNotEmpty) return _displayName;
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null) return 'Explorador';
      final local = email.split('@').first.split('.').first
          .replaceAll(RegExp(r'[0-9]'), '').trim();
      if (local.isEmpty) return 'Explorador';
      return local[0].toUpperCase() + local.substring(1);
    }();
    final h = DateTime.now().hour;
    if (h < 13) return 'Buenos días,\n$name';
    if (h < 20) return 'Buenas tardes,\n$name';
    return 'Buenas noches,\n$name';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoading) {
                return _LoadingShimmer(kc: kc);
              }
              if (state is TaskError) {
                return _ErrorView(message: state.message, kc: kc);
              }

              final tasks = state is TaskLoaded ? state.tasks : <Task>[];
              final pending = tasks.where((t) => !t.isDone).toList();
              final done = tasks.where((t) => t.isDone).toList();
              final totalEnergy =
                  pending.fold<int>(0, (s, t) => s + t.energyLevel);
              const maxEnergy = 20;
              final energyRatio = (totalEnergy / maxEnergy).clamp(0.0, 1.0);
              final xp = XpCalculator.totalXp(tasks);
              final lvl = XpCalculator.level(xp);
              final lvlName = XpCalculator.levelName(lvl);
              final lvlProgress = XpCalculator.levelProgress(xp);

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── HERO HEADER ────────────────────────────────
                  SliverToBoxAdapter(
                    child: _HeroHeader(
                      orbitCtrl: _orbitCtrl,
                      dateLabel: _dateLabel(),
                      greeting: _greeting(),
                      kc: kc,
                      isDark: isDark,
                      xp: xp,
                      lvl: lvl,
                      lvlName: lvlName,
                      lvlProgress: lvlProgress,
                    ),
                  ),

                  // ── ENERGY + AI CARDS ───────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          KScreen.hPad(context), 0,
                          KScreen.hPad(context), AppSpacing.md),
                      child: Column(
                        children: [
                          // Energy card
                          _EnergyCard(
                            kc: kc,
                            pending: pending.length,
                            done: done.length,
                            energyRatio: energyRatio,
                          )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                          const SizedBox(height: AppSpacing.md),

                          // AI CTA
                          _AiCta(kc: kc)
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 400.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                        ],
                      ),
                    ),
                  ),

                  // ── SECTION HEADER: PENDIENTES ─────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          KScreen.hPad(context), AppSpacing.md,
                          KScreen.hPad(context), AppSpacing.sm),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 14,
                            decoration: BoxDecoration(
                              color: kc.accent,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('PENDIENTES',
                              style: AppTypography.mono11
                                  .copyWith(color: kc.text2,
                                      fontWeight: FontWeight.w600)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: kc.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text('${pending.length}',
                                style: AppTypography.mono11
                                    .copyWith(color: kc.accent,
                                        fontSize: 10)),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.go('/tasks'),
                            child: Row(
                              children: [
                                Text('Ver todas',
                                    style: AppTypography.caption12
                                        .copyWith(color: kc.accent)),
                                const SizedBox(width: 2),
                                Icon(Icons.arrow_forward_ios,
                                    size: 10, color: kc.accent),
                              ],
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 350.ms, duration: 300.ms),
                    ),
                  ),

                  // ── TASK LIST ─────────────────────────────────
                  if (pending.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxxl),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: kc.success, size: 40),
                              const SizedBox(height: 12),
                              Text('Todo al día',
                                  style: AppTypography.heading18
                                      .copyWith(color: kc.text2)),
                              const SizedBox(height: 4),
                              Text('No hay tareas pendientes',
                                  style: AppTypography.body13
                                      .copyWith(color: kc.text3)),
                            ],
                          ),
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
                                horizontal: KScreen.hPad(ctx),
                                vertical: AppSpacing.xs),
                            child: TaskCard(
                              task: pending[i],
                              onTap: () =>
                                  context.push('/task/${pending[i].id}'),
                              onToggle: () =>
                                  context.read<TaskBloc>().add(
                                      ToggleTaskRequested(id: pending[i].id)),
                            )
                                .animate()
                                .fadeIn(
                                    delay: Duration(milliseconds: 400 + i * 60),
                                    duration: 350.ms)
                                .slideY(
                                    begin: 0.15,
                                    end: 0,
                                    curve: Curves.easeOut),
                          );
                        },
                        childCount: pending.length.clamp(0, 4),
                      ),
                    ),

                  // ── COMPLETED SECTION ─────────────────────────
                  if (done.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            KScreen.hPad(context), AppSpacing.xxl,
                            KScreen.hPad(context), AppSpacing.sm),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 14,
                              decoration: BoxDecoration(
                                color: kc.success,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('COMPLETADAS',
                                style: AppTypography.mono11
                                    .copyWith(color: kc.text2,
                                        fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: kc.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text('${done.length}',
                                  style: AppTypography.mono11
                                      .copyWith(color: kc.success,
                                          fontSize: 10)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: KScreen.hPad(ctx),
                              vertical: AppSpacing.xs),
                          child: Opacity(
                            opacity: 0.45,
                            child: TaskCard(
                              task: done[i],
                              onTap: () =>
                                  context.push('/task/${done[i].id}'),
                              onToggle: () =>
                                  context.read<TaskBloc>().add(
                                      ToggleTaskRequested(id: done[i].id)),
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

          // FAB
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

// ─────────────────────────────────────────────────────────
// Hero Header con gradiente radial y orb animado
// ─────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final AnimationController orbitCtrl;
  final String dateLabel;
  final String greeting;
  final KairosColors kc;
  final bool isDark;
  final int xp;
  final int lvl;
  final String lvlName;
  final double lvlProgress;

  const _HeroHeader({
    required this.orbitCtrl,
    required this.dateLabel,
    required this.greeting,
    required this.kc,
    required this.isDark,
    required this.xp,
    required this.lvl,
    required this.lvlName,
    required this.lvlProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Orb de fondo animado
        AnimatedBuilder(
          animation: orbitCtrl,
          builder: (_, __) {
            final angle = orbitCtrl.value * 2 * math.pi;
            final ox = math.cos(angle) * 30.0;
            final oy = math.sin(angle) * 20.0;
            return Positioned(
              top: -60 + oy,
              right: -40 + ox,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kc.accent.withValues(alpha: isDark ? 0.18 : 0.12),
                      kc.accent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Contenido
        Padding(
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).padding.top + 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: date + notification bell
              Row(
                children: [
                  Text(dateLabel,
                      style: AppTypography.mono11.copyWith(color: kc.text3))
                      .animate()
                      .fadeIn(duration: 400.ms),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.black.withValues(alpha: 0.05),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Icon(Icons.notifications_outlined,
                          color: kc.text2, size: 17),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms),
                ],
              ),
              const SizedBox(height: 20),

              // Greeting — grande y bold
              Text(
                greeting,
                style: AppTypography.heading28.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 500.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),

              const SizedBox(height: 16),

              // XP Badge
              _XpBadge(
                kc: kc,
                lvl: lvl,
                lvlName: lvlName,
                xp: xp,
                progress: lvlProgress,
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms)
                  .slideX(begin: -0.1, end: 0, curve: Curves.easeOut),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// XP Badge visual
// ─────────────────────────────────────────────────────────

class _XpBadge extends StatelessWidget {
  final KairosColors kc;
  final int lvl;
  final String lvlName;
  final int xp;
  final double progress;

  const _XpBadge({
    required this.kc,
    required this.lvl,
    required this.lvlName,
    required this.xp,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kc.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kc.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nivel badge circular
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kc.accent,
                  kc.accent.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Center(
              child: Text(
                '$lvl',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lvlName,
                  style: AppTypography.mono11
                      .copyWith(color: kc.accent, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: kc.accent.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(kc.accent),
                    minHeight: 3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text('$xp XP',
              style: AppTypography.mono11
                  .copyWith(color: kc.text3, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Energy Card rediseñada
// ─────────────────────────────────────────────────────────

class _EnergyCard extends StatelessWidget {
  final KairosColors kc;
  final int pending;
  final int done;
  final double energyRatio;

  const _EnergyCard({
    required this.kc,
    required this.pending,
    required this.done,
    required this.energyRatio,
  });

  Color _barColor() {
    if (energyRatio < 0.4) return kc.success;
    if (energyRatio < 0.75) return kc.warning;
    return kc.danger;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = _barColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.electric_bolt, size: 14, color: barColor),
              const SizedBox(width: 6),
              Text('Carga energética hoy',
                  style: AppTypography.caption12
                      .copyWith(color: kc.text2, fontWeight: FontWeight.w500)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${(energyRatio * 100).round()}%',
                  style: AppTypography.mono11
                      .copyWith(color: barColor, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar with gradient and glow
          Stack(
            children: [
              // Track
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              // Fill
              FractionallySizedBox(
                widthFactor: energyRatio,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [barColor.withValues(alpha: 0.7), barColor],
                    ),
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              _StatPill(
                  icon: Icons.pending_outlined,
                  label: '$pending pendientes',
                  color: kc.text3),
              const SizedBox(width: 12),
              _StatPill(
                  icon: Icons.check_circle_outline,
                  label: '$done completadas',
                  color: kc.success),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: AppTypography.mono11.copyWith(color: color, fontSize: 10)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// AI CTA con borde animado pulsante
// ─────────────────────────────────────────────────────────

class _AiCta extends StatefulWidget {
  final KairosColors kc;
  const _AiCta({required this.kc});

  @override
  State<_AiCta> createState() => _AiCtaState();
}

class _AiCtaState extends State<_AiCta> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glow = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kc = widget.kc;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/optimize');
      },
      child: AnimatedBuilder(
        animation: _glow,
        builder: (_, __) {
          final g = _glow.value;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kc.accent.withValues(alpha: 0.14 + g * 0.06),
                  kc.accent.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: kc.accent.withValues(alpha: 0.35 + g * 0.25),
                width: 1.0 + g * 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: kc.accent.withValues(alpha: 0.08 + g * 0.08),
                  blurRadius: 20,
                  spreadRadius: g * 2,
                ),
              ],
            ),
            child: Row(
              children: [
                // Icono IA con gradiente
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kc.accent, kc.accent.withValues(alpha: 0.75)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kc.accent.withValues(alpha: 0.35 + g * 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Optimizar mi día con IA',
                          style: AppTypography.body14.copyWith(
                              fontWeight: FontWeight.w600,
                              color: kc.accent)),
                      const SizedBox(height: 2),
                      Text('Reordena por prioridad y energía',
                          style: AppTypography.caption12
                              .copyWith(color: kc.text3)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: kc.accent.withValues(alpha: 0.7),
                    size: 14),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Loading shimmer
// ─────────────────────────────────────────────────────────

class _LoadingShimmer extends StatelessWidget {
  final KairosColors kc;
  const _LoadingShimmer({required this.kc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20,
          20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(w: 160, h: 14, kc: kc),
          const SizedBox(height: 16),
          _ShimmerBox(w: double.infinity, h: 36, kc: kc),
          const SizedBox(height: 8),
          _ShimmerBox(w: 120, h: 20, kc: kc),
          const SizedBox(height: 24),
          _ShimmerBox(w: double.infinity, h: 80, kc: kc, radius: 16),
          const SizedBox(height: 12),
          _ShimmerBox(w: double.infinity, h: 64, kc: kc, radius: 16),
          const SizedBox(height: 24),
          for (int i = 0; i < 3; i++) ...[
            _ShimmerBox(w: double.infinity, h: 72, kc: kc, radius: 12),
            const SizedBox(height: 8),
          ],
        ],
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1200.ms, color: kc.accent.withValues(alpha: 0.06)),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double w;
  final double h;
  final KairosColors kc;
  final double radius;

  const _ShimmerBox(
      {required this.w, required this.h, required this.kc, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final KairosColors kc;
  const _ErrorView({required this.message, required this.kc});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: kc.danger, size: 40),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTypography.body13.copyWith(color: kc.text2)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  context.read<TaskBloc>().add(const LoadTasksRequested()),
              child: Text('Reintentar',
                  style: AppTypography.body13.copyWith(color: kc.accent)),
            ),
          ],
        ),
      ),
    );
  }
}
