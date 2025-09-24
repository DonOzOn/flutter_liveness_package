import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

void main() {
  group('LivenessCheckScreen Widget Tests', () {
    testWidgets('should render with default configuration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: LivenessCheckScreen(config: LivenessCheckConfig())),
      );

      // Should render without throwing
      expect(find.byType(LivenessCheckScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display custom header when provided', (
      WidgetTester tester,
    ) async {
      const headerText = 'Custom Header Text';

      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              customHeader: Container(child: Text(headerText)),
            ),
          ),
        ),
      );

      expect(find.text(headerText), findsOneWidget);
    });

    testWidgets('should display custom bottom widget when provided', (
      WidgetTester tester,
    ) async {
      const bottomText = 'Custom Bottom Widget';

      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              customBottomWidget: Container(child: Text(bottomText)),
            ),
          ),
        ),
      );

      expect(find.text(bottomText), findsOneWidget);
    });

    testWidgets('should display loading overlay when showLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(showLoading: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('should display custom loading widget when provided', (
      WidgetTester tester,
    ) async {
      const loadingText = 'Custom Loading';

      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              showLoading: true,
              customLoadingWidget: Container(child: Text(loadingText)),
            ),
          ),
        ),
      );

      expect(find.text(loadingText), findsOneWidget);
    });

    testWidgets('should display try again button for fail status', (
      WidgetTester tester,
    ) async {
      const tryAgainText = 'Try Again';

      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              status: LivenessStatus.fail,
              settings: LivenessCheckSettings(showTryAgainButton: true),
              messages: LivenessCheckMessages(tryAgainButtonText: tryAgainText),
            ),
          ),
        ),
      );

      expect(find.text(tryAgainText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets(
      'should hide try again button when showTryAgainButton is false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: LivenessCheckScreen(
              config: LivenessCheckConfig(
                status: LivenessStatus.fail,
                settings: LivenessCheckSettings(showTryAgainButton: false),
              ),
            ),
          ),
        );

        expect(find.text('Try Again'), findsNothing);
      },
    );

    testWidgets(
      'should not show try again button when custom bottom widget is provided',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: LivenessCheckScreen(
              config: LivenessCheckConfig(
                status: LivenessStatus.fail,
                customBottomWidget: Container(child: Text('Custom Bottom')),
                settings: LivenessCheckSettings(showTryAgainButton: true),
              ),
            ),
          ),
        );

        expect(find.text('Try Again'), findsNothing);
        expect(find.text('Custom Bottom'), findsOneWidget);
      },
    );

    testWidgets(
      'should call onTryAgain callback when try again button is pressed',
      (WidgetTester tester) async {
        bool tryAgainCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: LivenessCheckScreen(
              config: LivenessCheckConfig(
                status: LivenessStatus.fail,
                callbacks: LivenessCheckCallbacks(
                  onTryAgain: () => tryAgainCalled = true,
                ),
                settings: LivenessCheckSettings(showTryAgainButton: true),
              ),
            ),
          ),
        );

        final tryAgainButton = find.text('Try Again');
        expect(tryAgainButton, findsOneWidget);

        await tester.tap(tryAgainButton);
        await tester.pump();

        expect(tryAgainCalled, true);
      },
    );

    testWidgets('should display placeholder text when provided', (
      WidgetTester tester,
    ) async {
      const placeholderText = 'Custom placeholder message';

      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(placeholder: placeholderText),
          ),
        ),
      );

      expect(find.text(placeholderText), findsOneWidget);
    });

    testWidgets('should apply custom theme colors', (
      WidgetTester tester,
    ) async {
      const primaryColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              theme: LivenessCheckTheme(primaryColor: primaryColor),
            ),
          ),
        ),
      );

      // The widget should render without errors with custom colors
      expect(find.byType(LivenessCheckScreen), findsOneWidget);
    });

    testWidgets('should handle different border styles', (
      WidgetTester tester,
    ) async {
      // Test solid border
      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              theme: LivenessCheckTheme(borderStyle: CircleBorderStyle.solid),
            ),
          ),
        ),
      );
      expect(find.byType(LivenessCheckScreen), findsOneWidget);

      // Test dashed border
      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              theme: LivenessCheckTheme(borderStyle: CircleBorderStyle.dashed),
            ),
          ),
        ),
      );
      expect(find.byType(LivenessCheckScreen), findsOneWidget);
    });

    testWidgets('should handle status changes', (WidgetTester tester) async {
      // Start with init status
      const config1 = LivenessCheckConfig(status: LivenessStatus.init);

      await tester.pumpWidget(
        MaterialApp(home: LivenessCheckScreen(config: config1)),
      );
      expect(find.byType(LivenessCheckScreen), findsOneWidget);

      // Change to success status
      const config2 = LivenessCheckConfig(status: LivenessStatus.success);

      await tester.pumpWidget(
        MaterialApp(home: LivenessCheckScreen(config: config2)),
      );
      expect(find.byType(LivenessCheckScreen), findsOneWidget);

      // Change to fail status
      const config3 = LivenessCheckConfig(status: LivenessStatus.fail);

      await tester.pumpWidget(
        MaterialApp(home: LivenessCheckScreen(config: config3)),
      );
      expect(find.byType(LivenessCheckScreen), findsOneWidget);
    });
  });

  group('LivenessCheckScreen Integration Tests', () {
    testWidgets('should integrate all custom widgets correctly', (
      WidgetTester tester,
    ) async {
      bool successCalled = false;
      bool tryAgainCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              customHeader: Container(child: Text('Header')),
              customBottomWidget: Container(child: Text('Bottom')),
              customLoadingWidget: Container(child: Text('Loading')),
              showLoading: false,
              status: LivenessStatus.init,
              placeholder: 'Please position your face',
              theme: LivenessCheckTheme(
                borderStyle: CircleBorderStyle.dashed,
                primaryColor: Colors.purple,
                borderColor: Colors.green,
                fontFamily: 'TestFont',
              ),
              settings: LivenessCheckSettings(
                requiredBlinkCount: 5,
                maxRetryAttempts: 2,
                showTryAgainButton: true,
              ),
              messages: LivenessCheckMessages(
                title: 'Face Verification',
                tryAgainButtonText: 'Retry',
              ),
              callbacks: LivenessCheckCallbacks(
                onSuccess: () => successCalled = true,
                onTryAgain: () => tryAgainCalled = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
      expect(find.text('Please position your face'), findsOneWidget);
      expect(find.byType(LivenessCheckScreen), findsOneWidget);
    });
  });
}
