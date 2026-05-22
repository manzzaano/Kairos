import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/theme/kairos_logo.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_shapes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      tag: '01 / OFFLINE-FIRST',
      title: 'Tu agenda,\nsiempre disponible',
      accent: Color(0xFF4ADE80),
    ),
    _SlideData(
      tag: '02 / SMART SCHEDULING',
      title: 'Optimiza tu día\ncon un toque',
      accent: Color(0xFFFB923C),
    ),
    _SlideData(
      tag: '03 / DEEP WORK',
      title: 'Modo enfoque\nsin distracciones',
      accent: Color(0xFFA855F7),
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: kc.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: Text('Saltar',
                    style: AppTypography.body13
                        .copyWith(color: kc.text2)),
              ),
            ),
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
                        Text(s.tag,
                            style: AppTypography.mono11
                                .copyWith(color: s.accent)),
                        const SizedBox(height: 16),
                        Text(s.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                letterSpacing: -0.7,
                                color: kc.text)),
                        const SizedBox(height: 48),
                        _Illustration(accent: s.accent),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: Row(
                children: [
                  Row(
                    children: List.generate(_slides.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: active ? 18 : 6,
                        height: 3,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: active ? slide.accent : kc.line2,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: slide.accent,
                        borderRadius:
                            BorderRadius.circular(AppShapes.fabRadius),
                      ),
                      child: Icon(
                        _currentPage < _slides.length - 1
                            ? Icons.arrow_forward
                            : Icons.check,
                        color: const Color(0xFF1A0A00),
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
    );
  }
}

class _Illustration extends StatelessWidget {
  final Color accent;
  const _Illustration({required this.accent});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kc.line),
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.15),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
          ),
          KairosLogoMark(
            size: 48,
            color: accent,
            strokeWidth: 1.5,
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final String tag;
  final String title;
  final Color accent;
  const _SlideData({
    required this.tag,
    required this.title,
    required this.accent,
  });
}
