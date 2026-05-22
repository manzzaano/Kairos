import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_shapes.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../sync/presentation/widgets/sync_sheet.dart';
import '../../../sync/presentation/widgets/conflict_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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

    return Scaffold(
      backgroundColor: kc.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 64, 20, 12),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFB923C), Color(0xFFC2410C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text('IM',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A0A00))),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ismael Manzano',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('ismael@email.com',
                          style: AppTypography.mono11
                              .copyWith(color: kc.text3)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SectionHeader('SINCRONIZACIÓN'),
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
                    trailing: Text('1 PENDIENTE',
                        style: AppTypography.mono11
                            .copyWith(color: kc.warning)),
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

            _SectionHeader('APARIENCIA'),
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
                          activeThumbColor: kc.accent,
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

            _SectionHeader('PREFERENCIAS'),
            SolidCard(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: [
                  _ActionRow(
                      icon: Icons.notifications_outlined,
                      label: 'Notificaciones',
                      sub: 'Activadas',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Configuración de notificaciones disponible próximamente')),
                        );
                      }),
                  Divider(color: kc.line, height: 1),
                  _ActionRow(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacidad y datos',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Política de privacidad disponible próximamente')),
                        );
                      }),
                  Divider(color: kc.line, height: 1),
                  _ActionRow(
                      icon: Icons.settings_outlined,
                      label: 'Ajustes avanzados',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ajustes avanzados disponibles próximamente')),
                        );
                      }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.go('/login');
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
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                'KAIROS 2.0.1 · BUILD 2026.04.27 · IML',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 10, color: kc.text4),
              ),
            ),
            const SizedBox(height: 80),
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
  late bool _syncActive;

  @override
  void initState() {
    super.initState();
    _syncActive = true;
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _syncActive = !_syncActive;
          });
        },
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
                      ? 'Realm · Última sync: hace 2 min'
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

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final VoidCallback onTap;
  const _ActionRow({
    required this.icon,
    required this.label,
    this.sub,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.body13),
                  if (sub != null)
                    Text(sub!,
                        style: AppTypography.caption12
                            .copyWith(color: kc.text3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: kc.text3, size: 14),
          ],
        ),
      ),
    );
  }
}
