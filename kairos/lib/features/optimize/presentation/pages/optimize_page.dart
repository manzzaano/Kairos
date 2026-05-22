import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';

class OptimizePage extends StatefulWidget {
  const OptimizePage({super.key});

  @override
  State<OptimizePage> createState() => _OptimizePageState();
}

class _OptimizePageState extends State<OptimizePage>
    with TickerProviderStateMixin {
  int _step = 0;
  late final AnimationController _orbitCtrl;

  static const _steps = [
    'Analizando tareas pendientes',
    'Calculando prioridades',
    'Evaluando niveles de energía',
    'Reorganizando secuencia',
    'Aplicando plan óptimo',
  ];

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _advance();
  }

  void _advance() async {
    for (var i = 0; i <= _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      setState(() => _step = i);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: kc.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kc.bg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kc.line),
                  ),
                  child: Icon(Icons.close,
                      size: 18, color: kc.text3),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _OrbitRing(
                          radius: 90,
                          border: kc.line,
                          duration: 6,
                          child: _Planet(accent: kc.accent),
                        ),
                        _OrbitRing(
                          radius: 65,
                          border: kc.line2,
                          duration: 4,
                          child: _Planet(accent: kc.accent2),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kc.bg2,
                            border: Border.all(color: kc.line2),
                          ),
                          child: Icon(Icons.auto_awesome,
                              size: 20, color: kc.accent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('OPTIMIZANDO',
                      style: AppTypography.mono11
                          .copyWith(color: kc.accent)),
                  const SizedBox(height: 8),
                  Text('Reorganizando tu día',
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: kc.text)),
                  const SizedBox(height: 32),
                  ...List.generate(_steps.length, (i) {
                    final done = i < _step;
                    final active = i == _step;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (done)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kc.accent,
                              ),
                              child: const Icon(Icons.check,
                                  size: 14,
                                  color: Color(0xFF1A0A00)),
                            )
                          else if (active)
                            _PulseDot(color: kc.accent)
                          else
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: kc.line2),
                              ),
                            ),
                          const SizedBox(width: 12),
                          Text(_steps[i],
                              style: AppTypography.body13.copyWith(
                                color: done
                                    ? kc.text2
                                    : active
                                        ? kc.text
                                        : kc.text3,
                              )),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitRing extends StatelessWidget {
  final double radius;
  final Color border;
  final int duration;
  final Widget child;
  const _OrbitRing({
    required this.radius,
    required this.border,
    required this.duration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: border),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 2 * 3.14159),
            duration: Duration(seconds: duration),
            builder: (_, t, __) {
              return Transform.rotate(
                angle: t,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Transform.translate(
                    offset: Offset(0, -radius),
                    child: child,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Planet extends StatelessWidget {
  final Color accent;
  const _Planet({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent,
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(
              alpha: 0.3 + _ctrl.value * 0.5),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
