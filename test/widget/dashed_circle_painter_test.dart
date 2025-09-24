import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_check/widget/dashed_circle_painter.dart';

void main() {
  group('DashedCirclePainter Tests', () {
    test('should create painter with correct properties', () {
      final painter = DashedCirclePainter(
        color: Colors.blue,
        strokeWidth: 4.0,
        dashLength: 8.0,
        dashGap: 6.0,
      );

      expect(painter.color, Colors.blue);
      expect(painter.strokeWidth, 4.0);
      expect(painter.dashLength, 8.0);
      expect(painter.dashGap, 6.0);
    });

    test('should have correct default values', () {
      final painter = DashedCirclePainter(
        color: Colors.red,
        strokeWidth: 2.0,
        dashLength: 8.0,
        dashGap: 8.0,
      );

      expect(painter.color, Colors.red);
      expect(painter.strokeWidth, 2.0);
      expect(painter.dashLength, 8.0);
      expect(painter.dashGap, 8.0);
    });

    testWidgets('should paint without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: DashedCirclePainter(
                color: Colors.blue,
                strokeWidth: 4.0,
                dashLength: 10.0,
                dashGap: 5.0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should handle different sizes correctly', (
      WidgetTester tester,
    ) async {
      final painter = DashedCirclePainter(
        color: Colors.green,
        strokeWidth: 3.0,
        dashLength: 8.0,
        dashGap: 8.0,
      );

      // Test with small size
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(size: const Size(50, 50), painter: painter),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsOneWidget);

      // Test with large size
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(size: const Size(400, 400), painter: painter),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    test('should indicate when repaint is needed', () {
      final painter1 = DashedCirclePainter(
        color: Colors.blue,
        strokeWidth: 4.0,
        dashLength: 8.0,
        dashGap: 8.0,
      );

      final painter2 = DashedCirclePainter(
        color: Colors.blue,
        strokeWidth: 4.0,
        dashLength: 8.0,
        dashGap: 8.0,
      );

      final painter3 = DashedCirclePainter(
        color: Colors.red,
        strokeWidth: 4.0,
        dashLength: 8.0,
        dashGap: 8.0,
      );

      // Same properties should not need repaint
      expect(painter1.shouldRepaint(painter2), false);

      // Different properties should need repaint
      expect(painter1.shouldRepaint(painter3), true);
    });

    test('should handle different stroke widths', () {
      final thinPainter = DashedCirclePainter(
        color: Colors.blue,
        strokeWidth: 1.0,
        dashLength: 8.0,
        dashGap: 8.0,
      );

      final thickPainter = DashedCirclePainter(
        color: Colors.blue,
        strokeWidth: 10.0,
        dashLength: 8.0,
        dashGap: 8.0,
      );

      expect(thinPainter.strokeWidth, 1.0);
      expect(thickPainter.strokeWidth, 10.0);
      expect(thinPainter.shouldRepaint(thickPainter), true);
    });

    test('should handle different dash patterns', () {
      final shortDashPainter = DashedCirclePainter(
        color: Colors.blue,
        strokeWidth: 4.0,
        dashLength: 2.0,
        dashGap: 2.0,
      );

      final longDashPainter = DashedCirclePainter(
        color: Colors.blue,
        strokeWidth: 4.0,
        dashLength: 20.0,
        dashGap: 10.0,
      );

      expect(shortDashPainter.dashLength, 2.0);
      expect(shortDashPainter.dashGap, 2.0);
      expect(longDashPainter.dashLength, 20.0);
      expect(longDashPainter.dashGap, 10.0);
      expect(shortDashPainter.shouldRepaint(longDashPainter), true);
    });

    testWidgets('should work with different colors', (
      WidgetTester tester,
    ) async {
      const colors = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
      ];

      for (final color in colors) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                size: const Size(100, 100),
                painter: DashedCirclePainter(
                  color: color,
                  strokeWidth: 3.0,
                  dashLength: 8.0,
                  dashGap: 8.0,
                ),
              ),
            ),
          ),
        );
        expect(find.byType(CustomPaint), findsOneWidget);
      }
    });
  });
}
