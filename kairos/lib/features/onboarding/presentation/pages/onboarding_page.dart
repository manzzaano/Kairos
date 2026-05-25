import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/theme/kairos_logo.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_shapes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  late final AnimationController _orbCtrl;

  static const _slides = [
    _SlideData(
      tag: '01 / OFFLINE-FIRST',
      title: 'Tu agenda,\nsiempre disponible',
      sub: 'Trabaja sin conexión. Tus tareas se sincronizan automáticamente en segundo plano.',
      accent: Color(0xFF4ADE80),
      illustration: _IllustrationType.offline,
    ),
    _SlideData(
      tag: '02 / SMART SCHEDULING',
      title: 'Optimiza tu día\ncon un toque',
      sub: 'La IA de KAIROS analiza tus tareas y sugiere el orden óptimo para maximizar tu energía.',
      accent: Color(0xFFFB923C),
      illustration: _IllustrationType.ai,
    ),
    _SlideData(
      tag: '03 / DEEP WORK',
      title: 'Modo enfoque\nsin distracciones',
      sub: 'Temporizador Pomodoro integrado. Bloquea distracciones y gana XP por cada sesión.',
      accent: Color(0xFFA855F7),
      illustration: _IllustrationType.focus,
    ),
  ];

  Future<void> _next() async {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('kairos_onboarding_done', true);
      if (mounted) context.go('/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final slide = _slides[_currentPage];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kc.bg,
      body: Stack(
        children: [
          // Orb de fondo animado
          AnimatedBuilder(
            animation: _orbCtrl,
            builder: (context, _) {
              final g = CurvedAnimation(
                parent: _orbCtrl,
                curve: Curves.easeInOut,
              ).value;
              return Positioned(
                top: size.height * 0.1 - g * 20,
                right: -60,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        slide.accent.withValues(alpha: 0.10 + g * 0.04),
                        slide.accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo text
                      Text('KAIROS',
                          style: AppTypography.mono11.copyWith(
                              color: kc.text3, letterSpacing: 2)),
                      // Skip button
                      TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('kairos_onboarding_done', true);
                          if (context.mounted) context.go('/login');
                        },
                        child: Text('Saltar',
                            style: AppTypography.body13.copyWith(color: kc.text2)),
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) {
                      final s = _slides[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Illustration
                            _OnboardingIllustration(slide: s)
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .scale(
                                  begin: const Offset(0.85, 0.85),
                                  curve: Curves.easeOutBack,
                                ),
                            const SizedBox(height: 48),

                            // Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: s.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: s.accent.withValues(alpha: 0.3)),
                              ),
                              child: Text(s.tag,
                                  style: AppTypography.mono11.copyWith(
                                      color: s.accent,
                                      fontWeight: FontWeight.w700)),
                            )
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 400.ms),
                            const SizedBox(height: 16),

                            // Title
                            Text(s.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    letterSpacing: -0.8,
                                    color: kc.text))
                            .animate()
                            .fadeIn(delay: 160.ms, duration: 400.ms)
                            .slideY(begin: 0.1, curve: Curves.easeOut),
                            const SizedBox(height: 16),

                            // Sub
                            Text(s.sub,
                                textAlign: TextAlign.center,
                                style: AppTypography.body14.copyWith(
                                    color: kc.text2, height: 1.5))
                            .animate()
                            .fadeIn(delay: 220.ms, duration: 400.ms),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
                  child: Row(
                    children: [
                      // Page dots
                      Row(
                        children: List.generate(_slides.length, (i) {
                          final active = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            width: active ? 24 : 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: active ? slide.accent : kc.line2,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: slide.accent.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                      const Spacer(),

                      // Next/Done button
                      GestureDetector(
                        onTap: _next,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                slide.accent,
                                slide.accent.withValues(alpha: 0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppShapes.fabRadius),
                            boxShadow: [
                              BoxShadow(
                                color: slide.accent.withValues(alpha: 0.40),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            _currentPage < _slides.length - 1
                                ? Icons.arrow_forward_rounded
                                : Icons.check_rounded,
                            color: const Color(0xFF0A0A0A),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _IllustrationType { offline, ai, focus }

class _OnboardingIllustration extends StatefulWidget {
  final _SlideData slide;
  const _OnboardingIllustration({required this.slide});

  @override
  State<_OnboardingIllustration> createState() =>
      _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<_OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final g = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut).value;
          return CustomPaint(
            painter: _IllustrationPainter(
              accent: widget.slide.accent,
              type: widget.slide.illustration,
              pulse: g,
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.slide.accent.withValues(alpha: 0.25 + g * 0.20),
                      blurRadius: 24 + g * 12,
                    ),
                  ],
                ),
                child: KairosLogoMark(
                  size: 72,
                  color: widget.slide.accent,
                  strokeWidth: 1.8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  final Color accent;
  final _IllustrationType type;
  final double pulse;

  _IllustrationPainter({
    required this.accent,
    required this.type,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Ring externo
    final ringPaint1 = Paint()
      ..color = accent.withValues(alpha: 0.10 + pulse * 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, size.width / 2 - 2, ringPaint1);

    // Ring medio
    final ringPaint2 = Paint()
      ..color = accent.withValues(alpha: 0.18 + pulse * 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, size.width / 2 - 28, ringPaint2);

    // Dots orbitales (decorativos)
    final dotCount = type == _IllustrationType.ai ? 8 : 6;
    final radius = size.width / 2 - 14;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * math.pi +
          pulse * 0.3 * (type == _IllustrationType.focus ? -1 : 1);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      final isAccented = i % 3 == 0;
      final dotPaint = Paint()
        ..color = isAccented
            ? accent.withValues(alpha: 0.7 + pulse * 0.3)
            : accent.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), isAccented ? 3.5 : 2.0, dotPaint);
    }

    // Arc decorativo
    final arcPaint = Paint()
      ..color = accent.withValues(alpha: 0.25 + pulse * 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final sweepAngle = math.pi * (0.8 + pulse * 0.2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2 - 28),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_IllustrationPainter old) =>
      old.pulse != pulse || old.accent != accent;
}

class _SlideData {
  final String tag;
  final String title;
  final String sub;
  final Color accent;
  final _IllustrationType illustration;

  const _SlideData({
    required this.tag,
    required this.title,
    required this.sub,
    required this.accent,
    required this.illustration,
  });
}
