import 'dart:ui';
import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x66000000),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: const Color(0x26FFFFFF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 32,
                  offset: Offset(0, 8),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: active
                        ? BoxDecoration(
                            color: const Color(0x14FFFFFF),
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1AFFFFFF),
                                blurRadius: 1,
                                offset: Offset(0, 1),
                              ),
                            ],
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tabIcon(
                          type,
                          color: active ? kc.text : kc.text3,
                          sw: active ? 1.8 : 1.5,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: active ? kc.text : kc.text3,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
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

  static Widget _tabIcon(_Tab type, {required Color color, required double sw}) {
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
