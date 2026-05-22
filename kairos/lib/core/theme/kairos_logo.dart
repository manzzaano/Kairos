import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kairos_colors.dart';

class _KairosMarkPainter extends CustomPainter {
  final Color circleColor;
  final Color kColor;
  final double strokeWidth;

  _KairosMarkPainter({
    required this.circleColor,
    required this.kColor,
    this.strokeWidth = 1.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth - 1;

    final circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, circlePaint);

    final kPaint = Paint()
      ..color = kColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final innerR = radius * 0.55;
    final cx = center.dx;
    final cy = center.dy;
    final stemX = cx - innerR * 0.25;

    canvas.drawLine(
      Offset(stemX, cy - innerR),
      Offset(stemX, cy + innerR),
      kPaint,
    );

    canvas.drawLine(
      Offset(stemX, cy),
      Offset(cx + innerR * 0.7, cy - innerR * 0.75),
      kPaint,
    );

    canvas.drawLine(
      Offset(stemX, cy),
      Offset(cx + innerR * 0.7, cy + innerR * 0.75),
      kPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _KairosMarkPainter old) =>
      circleColor != old.circleColor ||
      kColor != old.kColor ||
      strokeWidth != old.strokeWidth;
}

class KairosLogoMark extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const KairosLogoMark({
    super.key,
    this.size = 80,
    this.color,
    this.strokeWidth = 1.8,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ??
        Theme.of(context).extension<KairosColors>()?.accent ??
        const Color(0xFFF0E6D7);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _KairosMarkPainter(
          circleColor: c,
          kColor: c,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class KairosLogo extends StatelessWidget {
  final double markSize;
  final double fontSize;
  final Color? color;

  const KairosLogo({
    super.key,
    this.markSize = 80,
    this.fontSize = 22,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ??
        Theme.of(context).extension<KairosColors>()?.text ??
        const Color(0xFFFAFAFA);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KairosLogoMark(size: markSize, color: c),
        const SizedBox(height: 16),
        Text(
          'KAIROS',
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: c,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
