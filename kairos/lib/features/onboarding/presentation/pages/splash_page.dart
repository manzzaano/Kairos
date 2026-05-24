import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/theme/kairos_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: kc.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) => Transform.rotate(
                      angle: _controller.value * 2 * 3.14159,
                      child: CustomPaint(
                        size: const Size(100, 100),
                        painter: _ArcPainter(),
                      ),
                    ),
                  ),
                  const KairosLogoMark(
                      size: 56,
                      color: Color(0xFFF0E6D7),
                      strokeWidth: 1.6,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('KAIROS',
                style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: kc.text)),
            const SizedBox(height: 8),
            Text('v2.0.1 · INICIANDO',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 11, color: kc.text3)),
            const SizedBox(height: 40),
            Text('realm · syncing local store...',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 12, color: kc.text4)),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFB923C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    canvas.drawArc(rect, -1.5708, 2.3562, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
