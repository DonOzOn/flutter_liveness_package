import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom painter that draws a dashed circular border.
///
/// This painter creates a circular border with evenly spaced dashes around
/// the circumference. The dashes are automatically adjusted to fit perfectly
/// around the circle, ensuring a symmetrical appearance.
///
/// Example:
/// ```dart
/// CustomPaint(
///   size: Size(300, 300),
///   painter: DashedCirclePainter(
///     color: Colors.blue,
///     strokeWidth: 4.0,
///     dashLength: 10.0,
///     dashGap: 8.0,
///   ),
/// )
/// ```
class DashedCirclePainter extends CustomPainter {
  /// The color of the dashed border.
  final Color color;

  /// The width of the stroke (border thickness).
  final double strokeWidth;

  /// The length of each dash segment.
  ///
  /// This value will be automatically adjusted to ensure dashes fit
  /// evenly around the circle's circumference.
  final double dashLength;

  /// The gap between each dash segment.
  final double dashGap;

  /// Creates a dashed circle painter.
  ///
  /// All parameters are required:
  /// - [color]: The color of the dashed border
  /// - [strokeWidth]: The thickness of the border
  /// - [dashLength]: The length of each dash
  /// - [dashGap]: The space between dashes
  DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
  });

  /// Paints the dashed circle on the canvas.
  ///
  /// This method calculates the optimal number of dashes to fit evenly around
  /// the circle and draws them with rounded caps for a smooth appearance.
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

  /// Determines whether the painter should repaint.
  ///
  /// Returns `true` if any of the visual properties (color, stroke width,
  /// dash length, or dash gap) have changed since the last paint.
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is! DashedCirclePainter ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap;
  }
}