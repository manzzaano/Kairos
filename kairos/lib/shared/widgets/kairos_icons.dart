import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';

abstract class _BaseIconPainter extends CustomPainter {
  final Color color;
  final double sw;

  _BaseIconPainter({required this.color, required this.sw});

  Paint get strokePaint => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = sw
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get fillPaint => Paint()
    ..color = color
    ..style = PaintingStyle.fill;
}

class _HomeIcon extends _BaseIconPainter {
  _HomeIcon({required super.color, required super.sw});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);
    // Casa: tejado + paredes + hueco de puerta central
    final path = Path()
      ..moveTo(3, 12)
      ..lineTo(12, 4)
      ..lineTo(21, 12)
      ..lineTo(21, 21)
      ..lineTo(15, 21)
      ..lineTo(15, 14)
      ..lineTo(9, 14)
      ..lineTo(9, 21)
      ..lineTo(3, 21)
      ..close();
    canvas.drawPath(path, strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HomeIcon old) => color != old.color || sw != old.sw;
}

class _ListIcon extends _BaseIconPainter {
  _ListIcon({required super.color, required super.sw});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);
    canvas.drawLine(const Offset(8, 6), const Offset(21, 6), strokePaint);
    canvas.drawLine(const Offset(8, 12), const Offset(21, 12), strokePaint);
    canvas.drawLine(const Offset(8, 18), const Offset(21, 18), strokePaint);
    final dotP = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(3.5, 6), sw * 0.5, dotP);
    canvas.drawCircle(const Offset(3.5, 12), sw * 0.5, dotP);
    canvas.drawCircle(const Offset(3.5, 18), sw * 0.5, dotP);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ListIcon old) => color != old.color || sw != old.sw;
}

class _FocusIcon extends _BaseIconPainter {
  _FocusIcon({required super.color, required super.sw});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);
    canvas.drawCircle(const Offset(12, 12), 9, strokePaint);
    canvas.drawCircle(const Offset(12, 12), 4, strokePaint);
    canvas.drawCircle(const Offset(12, 12), 1, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FocusIcon old) => color != old.color || sw != old.sw;
}

class _ChartIcon extends _BaseIconPainter {
  _ChartIcon({required super.color, required super.sw});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);
    canvas.drawLine(const Offset(3, 10), const Offset(3, 21), strokePaint);
    canvas.drawLine(const Offset(9, 4), const Offset(9, 21), strokePaint);
    canvas.drawLine(const Offset(15, 14), const Offset(15, 21), strokePaint);
    canvas.drawLine(const Offset(21, 8), const Offset(21, 21), strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChartIcon old) => color != old.color || sw != old.sw;
}

class _UserIcon extends _BaseIconPainter {
  _UserIcon({required super.color, required super.sw});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);
    canvas.drawCircle(const Offset(12, 8), 4, strokePaint);
    final path = Path()
      ..moveTo(4, 21)
      ..cubicTo(4, 17, 8, 14, 12, 14)
      ..cubicTo(16, 14, 20, 17, 20, 21);
    canvas.drawPath(path, strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _UserIcon old) => color != old.color || sw != old.sw;
}

class KairosIcon extends StatelessWidget {
  final _KairosIconType _type;
  final double size;
  final double sw;
  final Color? color;

  const KairosIcon.home({this.size = 20, this.sw = 1.6, this.color, super.key})
      : _type = _KairosIconType.home;

  const KairosIcon.list({this.size = 20, this.sw = 1.6, this.color, super.key})
      : _type = _KairosIconType.list;

  const KairosIcon.focus({this.size = 20, this.sw = 1.6, this.color, super.key})
      : _type = _KairosIconType.focus;

  const KairosIcon.chart({this.size = 20, this.sw = 1.6, this.color, super.key})
      : _type = _KairosIconType.chart;

  const KairosIcon.user({this.size = 20, this.sw = 1.6, this.color, super.key})
      : _type = _KairosIconType.user;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).extension<KairosColors>()?.text ??
        const Color(0xFFFAFAFA);
    return CustomPaint(
      size: Size(size, size),
      painter: _painter(c),
    );
  }

  CustomPainter _painter(Color c) => switch (_type) {
    _KairosIconType.home => _HomeIcon(color: c, sw: sw),
    _KairosIconType.list => _ListIcon(color: c, sw: sw),
    _KairosIconType.focus => _FocusIcon(color: c, sw: sw),
    _KairosIconType.chart => _ChartIcon(color: c, sw: sw),
    _KairosIconType.user => _UserIcon(color: c, sw: sw),
  };
}

enum _KairosIconType { home, list, focus, chart, user }
