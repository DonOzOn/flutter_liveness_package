import 'dart:math' as math;
import 'package:flutter/material.dart';

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Calculate the total circumference
    final circumference = 2 * math.pi * radius;

    // Calculate how many dashes fit around the circle
    final dashSpaceLength = dashLength + dashGap;
    final dashCount = (circumference / dashSpaceLength).floor();

    // Adjust dash parameters to fit perfectly around the circle
    final adjustedDashSpaceLength = circumference / dashCount;
    final adjustedDashLength = dashLength * (adjustedDashSpaceLength / dashSpaceLength);

    // Draw the dashed circle
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * adjustedDashSpaceLength / radius) - (math.pi / 2);
      final sweepAngle = adjustedDashLength / radius;

      final path = Path();
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is! DashedCirclePainter ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap;
  }
}