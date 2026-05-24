import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_shapes.dart';
import '../../../../core/utils/xp_calculator.dart';
import '../../../../core/utils/k_screen.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../sync/presentation/widgets/sync_sheet.dart';
import '../../../sync/presentation/widgets/conflict_sheet.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String _initials(String? email) {
    if (email == null || email.isEmpty) return '?';
    final parts = email.split('@').first.split('.');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return email.substring(0, email.length >= 2 ? 2 : 1).toUpperCase();
  }

  static const _accentOptions = [
    Color(0xFFFB923C),
    Color(0xFFA0B9D2),
    Color(0xFFF0E6D7),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFA855F7),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = themeState.mode == ThemeMode.dark;
    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email;
    final isGuest = user == null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            KScreen.hPad(context), KScreen.topPad(context),
            KScreen.hPad(context), 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Perfil',
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.7)),
            const SizedBox(height: 24),

            SolidCard(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(14),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: isGuest
                          ? const LinearGradient(
                              colors: [Color(0xFF6B7280), Color(0xFF374151)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFFFB923C), Color(0xFFC2410C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        isGuest ? '?' : _initials(userEmail),
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A0A00)),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGuest ? 'Modo invitado' : (userEmail ?? 'Usuario'),
                          style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isGuest ? 'Sin sincronización en la nube' : 'Cuenta sincronizada',
                          style: AppTypography.mono11.copyWith(
                              color: isGuest ? kc.warning : kc.success),
                        ),
                      ],
                    ),
                  ),
                  if (isGuest)
                    GestureDetector(
                      onTap: () => context.push('/login'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kc.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Entrar',
                            style: AppTypography.caption12.copyWith(
                                color: kc.accent, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── XP / Karma section ──────────────────────────────────────────
            const _SectionHeader('PROGRESIÓN'),
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                final tasks =
                    state is TaskLoaded ? state.tasks : <Task>[];
                final xp = XpCalculator.totalXp(tasks);
                final lvl = XpCalculator.level(xp);
                final lvlName = XpCalculator.levelName(lvl);
                final progress = XpCalculator.levelProgress(xp);
                final toNext = XpCalculator.xpToNext(xp);

                // Streak calculation
                int streak = 0;
                if (state is TaskLoaded) {
                  DateTime check = DateTime(DateTime.now().year,
                      DateTime.now().month, DateTime.now().day);
                  while (true) {
                    final hasAny = state.tasks.any((t) =>
                        t.completedAt != null &&
                        DateTime(t.completedAt!.year,
                                t.completedAt!.month,
                                t.completedAt!.day) ==
                            check);
                    if (!hasAny) break;
                    streak++;
                    check =
                        check.subtract(const Duration(days: 1));
                  }
                }
                final karmaLabel =
                    XpCalculator.karmaLabel(tasks, streak);

                return SolidCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Level badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: kc.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: kc.accent
                                      .withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt,
                                    color: kc.accent, size: 14),
                                const SizedBox(width: 4),
                                Text('NV $lvl',
                                    style: AppTypography.mono11
                                        .copyWith(
                                            color: kc.accent,
                                            fontWeight:
                                                FontWeight.w700)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(lvlName,
                                    style: AppTypography.body13
                                        .copyWith(
                                            fontWeight:
                                                FontWeight.w600)),
                                Text('$xp XP · faltan $toNext para NV ${lvl + 1}',
                                    style: AppTypography.mono11
                                        .copyWith(color: kc.text3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: kc.bg3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              kc.accent),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(karmaLabel,
                          style: AppTypography.caption12
                              .copyWith(color: kc.text2)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            const _SectionHeader('SINCRONIZACIÓN'),
            SolidCard(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: [
                  _SyncToggleRow(isDark: isDark),
                  Divider(color: kc.line, height: 1),
                  _SyncActionRow(
                    icon: Icons.sync,
                    label: 'Forzar sincronización',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const SyncSheet(),
                      );
                    },
                  ),
                  Divider(color: kc.line, height: 1),
                  _SyncActionRow(
                    icon: Icons.warning_amber_outlined,
                    label: 'Conflictos de versión',
                    trailing: null,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const ConflictSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const _SectionHeader('APARIENCIA'),
            SolidCard(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          isDark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: kc.text2,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  isDark ? 'Modo oscuro' : 'Modo claro',
                                  style: AppTypography.body13),
                              Text(
                                  isDark
                                      ? 'Toca para cambiar a claro'
                                      : 'Toca para cambiar a oscuro',
                                  style: AppTypography.caption12
                                      .copyWith(color: kc.text3)),
                            ],
                          ),
                        ),
                        Switch(
                          value: isDark,
                          onChanged: (_) =>
                              context.read<ThemeCubit>().toggleMode(),
                          thumbColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? kc.accent
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: kc.line, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Color de acento',
                            style: AppTypography.body13),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _accentOptions.map((color) {
                            final selected = themeState.accent == color;
                            return GestureDetector(
                              onTap: () => context
                                  .read<ThemeCubit>()
                                  .setAccent(color),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: selected
                                      ? Border.all(
                                          color: kc.text, width: 2.5)
                                      : Border.all(
                                          color: Colors.transparent,
                                          width: 2.5),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: color.withValues(
                                                alpha: 0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                ),
                                child: selected
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 18)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const _SectionHeader('PREFERENCIAS'),
            SolidCard(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(14),
              child: const _NotificationsRow(),
            ),
            const SizedBox(height: 24),

            if (!isGuest)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kc.danger,
                    side: BorderSide(color: kc.line),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppShapes.btnRadius)),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('Iniciar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kc.accent,
                    foregroundColor: const Color(0xFF1A0A00),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppShapes.btnRadius)),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                'KAIROS v3.0.0',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 10, color: kc.text4),
              ),
            ),
            SizedBox(height: KScreen.bottomPad(context)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text,
          style: AppTypography.mono11.copyWith(
              color: context.kc.text3,
              letterSpacing: 1.1)),
    );
  }
}

class _SyncToggleRow extends StatefulWidget {
  final bool isDark;
  const _SyncToggleRow({required this.isDark});

  @override
  State<_SyncToggleRow> createState() => _SyncToggleRowState();
}

class _SyncToggleRowState extends State<_SyncToggleRow> {
  bool _syncActive = true;
  String _lastSyncLabel = 'Nunca sincronizado';

  static const _kSyncActiveKey = 'sync_active';
  static const _kLastSyncKey = 'last_sync_ts';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final tsStr = prefs.getString(_kLastSyncKey);
    setState(() {
      _syncActive = prefs.getBool(_kSyncActiveKey) ?? true;
      if (tsStr != null) {
        final dt = DateTime.tryParse(tsStr);
        if (dt != null) _lastSyncLabel = _relativeTime(dt);
      }
    });
  }

  Future<void> _toggleSync(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSyncActiveKey, val);
    setState(() => _syncActive = val);
  }

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'hace un momento';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays} día${diff.inDays > 1 ? "s" : ""}';
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: GestureDetector(
        onTap: () => _toggleSync(!_syncActive),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 22,
              decoration: BoxDecoration(
                color: _syncActive ? kc.accent : kc.line,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: _syncActive ? 18 : 2,
                    top: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _syncActive
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_off_outlined,
                      size: 14,
                      color: _syncActive ? kc.success : kc.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _syncActive
                          ? 'Sincronización activa'
                          : 'Sincronización desactivada',
                      style: AppTypography.body13,
                    ),
                  ],
                ),
                Text(
                  _syncActive
                      ? 'Realm · $_lastSyncLabel'
                      : 'Sincronización offline',
                  style: AppTypography.mono11.copyWith(color: kc.text3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggle de notificaciones con estado persistido en SharedPreferences.
class _NotificationsRow extends StatefulWidget {
  const _NotificationsRow();

  @override
  State<_NotificationsRow> createState() => _NotificationsRowState();
}

class _NotificationsRowState extends State<_NotificationsRow> {
  bool _enabled = false;
  static const _kKey = 'notifications_enabled';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _enabled = prefs.getBool(_kKey) ?? false);
  }

  Future<void> _toggle() async {
    if (!_enabled) {
      // Solicitar permisos la primera vez
      final granted = await NotificationService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activa los permisos de notificaciones en Ajustes del sistema'),
            ),
          );
        }
        return;
      }
    } else {
      await NotificationService.cancelAll();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kKey, !_enabled);
    setState(() => _enabled = !_enabled);
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return GestureDetector(
      onTap: _toggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(
              _enabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              size: 20,
              color: _enabled ? kc.accent : kc.text3,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notificaciones',
                      style: AppTypography.body13),
                  Text(
                    _enabled ? 'Recordatorios activos' : 'Desactivadas',
                    style: AppTypography.mono11.copyWith(color: kc.text3),
                  ),
                ],
              ),
            ),
            // Toggle visual
            Container(
              width: 38,
              height: 22,
              decoration: BoxDecoration(
                color: _enabled ? kc.accent : kc.line,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: _enabled ? 18 : 2,
                    top: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  const _SyncActionRow({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: kc.text2, size: 18),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTypography.body13)),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right, color: kc.text3, size: 14),
          ],
        ),
      ),
    );
  }
}

