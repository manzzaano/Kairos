import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../shared/widgets/kairos_icons.dart';
import '../../../../shared/widgets/offline_banner.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      extendBody: false,
      backgroundColor: kc.bg,
      body: Stack(
        children: [
          navigationShell,
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: OfflineBanner()),
          ),
        ],
      ),
      bottomNavigationBar: _KairosTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) {
          if (i != navigationShell.currentIndex) {
            HapticFeedback.selectionClick();
            navigationShell.goBranch(i, initialLocation: true);
          }
        },
      ),
    );
  }
}

class _KairosTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _KairosTabBar({required this.currentIndex, required this.onTap});

  static const _tabs = [
    (_Tab.home, 'Hoy'),
    (_Tab.list, 'Tareas'),
    (_Tab.focus, 'Enfoque'),
    (_Tab.chart, 'Stats'),
    (_Tab.user, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x99000000)
                  : const Color(0xCCFFFFFF),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: isDark
                    ? const Color(0x26FFFFFF)
                    : const Color(0x1A000000),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final (type, label) = _tabs[i];
                final active = i == currentIndex;
                return Semantics(
                  label: 'Ir a $label',
                  selected: active,
                  button: true,
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            scale: active ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            child: _tabIcon(
                              type,
                              color: active ? kc.accent : kc.text3,
                              sw: active ? 1.8 : 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              color: active ? kc.accent : kc.text3,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Active dot indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            width: active ? 4 : 0,
                            height: active ? 4 : 0,
                            decoration: BoxDecoration(
                              color: kc.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _tabIcon(_Tab type,
      {required Color color, required double sw}) {
    return switch (type) {
      _Tab.home => KairosIcon.home(color: color, sw: sw),
      _Tab.list => KairosIcon.list(color: color, sw: sw),
      _Tab.focus => KairosIcon.focus(color: color, sw: sw),
      _Tab.chart => KairosIcon.chart(color: color, sw: sw),
      _Tab.user => KairosIcon.user(color: color, sw: sw),
    };
  }
}

enum _Tab { home, list, focus, chart, user }
