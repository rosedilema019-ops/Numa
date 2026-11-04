import 'package:flutter/material.dart';

class CalculatorMascot extends StatelessWidget {
  const CalculatorMascot({this.size = 44, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Calculator mascot',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: const CustomPaint(painter: _CalculatorMascotPainter()),
        ),
      ),
    );
  }
}

class _CalculatorMascotPainter extends CustomPainter {
  const _CalculatorMascotPainter();

  static const _blush = Color(0xFFF1B6C7);
  static const _cream = Color(0xFFFFF8FA);
  static const _rose = Color(0xFFC76D88);
  static const _palePink = Color(0xFFF7DCE5);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 48, size.height / 48);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 48, 48),
        const Radius.circular(15),
      ),
      Paint()..color = _blush,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 4, 32, 40),
        const Radius.circular(8),
      ),
      Paint()..color = _cream,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(12, 8, 24, 15),
        const Radius.circular(5),
      ),
      Paint()..color = _rose,
    );

    final facePaint = Paint()..color = _cream;
    canvas.drawCircle(const Offset(19, 14), 1.8, facePaint);
    canvas.drawCircle(const Offset(29, 14), 1.8, facePaint);
    canvas.drawPath(
      Path()
        ..moveTo(20, 18)
        ..quadraticBezierTo(24, 21, 28, 18),
      Paint()
        ..color = _cream
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    _drawKey(canvas, const Rect.fromLTWH(12, 27, 9, 5), _blush);
    _drawKey(canvas, const Rect.fromLTWH(23, 27, 13, 5), _palePink);
    _drawKey(canvas, const Rect.fromLTWH(12, 35, 7, 5), _rose);
    _drawKey(canvas, const Rect.fromLTWH(21, 35, 7, 5), _blush);
    _drawKey(canvas, const Rect.fromLTWH(30, 35, 6, 5), _palePink);
    canvas.restore();
  }

  void _drawKey(Canvas canvas, Rect rect, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _CalculatorMascotPainter oldDelegate) => false;
}
