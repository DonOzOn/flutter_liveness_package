import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

void main() {
  group('Integration Tests', () {
    testWidgets('Complete liveness flow simulation', (WidgetTester tester) async {
      LivenessStatus currentStatus = LivenessStatus.init;
      bool isLoading = false;
      int retryCount = 0;
      bool successCalled = false;
      String? errorMessage;

      late StateSetter setState;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setStateCallback) {
              setState = setStateCallback;
              return LivenessCheckScreen(
                config: LivenessCheckConfig(
                  status: currentStatus,
                  showLoading: isLoading,
                  theme: LivenessCheckTheme(
                    borderStyle: CircleBorderStyle.dashed,
                    borderColor: Colors.green,
                    primaryColor: Colors.blue,
                  ),
                  settings: LivenessCheckSettings(
                    maxRetryAttempts: 3,
                    showTryAgainButton: true,
                  ),
                  callbacks: LivenessCheckCallbacks(
                    onSuccess: () {
                      setState(() {
                        isLoading = true;
                      });

                      // Simulate processing
                      Future.delayed(Duration(milliseconds: 100), () {
                        setState(() {
                          currentStatus = LivenessStatus.success;
                          isLoading = false;
                          successCalled = true;
                        });
                      });
                    },
                    onError: (error) {
                      setState(() {
                        currentStatus = LivenessStatus.fail;
                        errorMessage = error;
                      });
                    },
                    onTryAgain: () {
                      setState(() {
                        currentStatus = LivenessStatus.init;
                        retryCount++;
                      });
                    },
                    onMaxRetryReached: (count) {
                      // Handle max retry
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Initial state should be init
      expect(currentStatus, LivenessStatus.init);
      expect(find.byType(LivenessCheckScreen), findsOneWidget);

      // Simulate error - change to fail status
      setState(() {
        currentStatus = LivenessStatus.fail;
      });
      await tester.pump();

      // Should show try again button for fail status
      expect(find.text('Try Again'), findsOneWidget);

      // Tap try again button
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      // Should be back to init status
      expect(currentStatus, LivenessStatus.init);
      expect(retryCount, 1);

      // Simulate success
      setState(() {
        currentStatus = LivenessStatus.success;
      });
      await tester.pump();

      expect(currentStatus, LivenessStatus.success);
    });

    testWidgets('Loading widget integration test', (WidgetTester tester) async {
      bool showLoading = false;
      late StateSetter setState;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setStateCallback) {
              setState = setStateCallback;
              return LivenessCheckScreen(
                config: LivenessCheckConfig(
                  showLoading: showLoading,
                  customLoadingWidget: Container(
                    color: Colors.red,
                    child: Text('Custom Loading'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Initially no loading
      expect(find.text('Custom Loading'), findsNothing);

      // Show loading
      setState(() {
        showLoading = true;
      });
      await tester.pump();

      // Should show custom loading
      expect(find.text('Custom Loading'), findsOneWidget);

      // Hide loading
      setState(() {
        showLoading = false;
      });
      await tester.pump();

      // Should hide loading
      expect(find.text('Custom Loading'), findsNothing);
    });

    testWidgets('Custom widgets integration test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              customHeader: AppBar(
                title: Text('Custom Verification'),
                backgroundColor: Colors.purple,
              ),
              customBottomWidget: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Instructions:'),
                    Text('1. Position your face in the circle'),
                    Text('2. Blink your eyes 3 times'),
                    Text('3. Keep device steady'),
                  ],
                ),
              ),
              status: LivenessStatus.init,
              theme: LivenessCheckTheme(
                borderStyle: CircleBorderStyle.dashed,
                dashLength: 12,
                dashGap: 6,
                borderColor: Colors.orange,
              ),
            ),
          ),
        ),
      );

      // Should find custom header
      expect(find.text('Custom Verification'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Should find custom bottom widget content
      expect(find.text('Instructions:'), findsOneWidget);
      expect(find.text('1. Position your face in the circle'), findsOneWidget);
      expect(find.text('2. Blink your eyes 3 times'), findsOneWidget);
      expect(find.text('3. Keep device steady'), findsOneWidget);
    });

    testWidgets('Theme integration test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              theme: LivenessCheckTheme(
                backgroundColor: Colors.black,
                primaryColor: Colors.cyan,
                successColor: Colors.lime,
                errorColor: Colors.deepOrange,
                borderColor: Colors.pink,
                borderStyle: CircleBorderStyle.dashed,
                borderWidth: 5.0,
                dashLength: 15.0,
                dashGap: 10.0,
                circleSize: 0.8,
                cameraPadding: 15.0,
                fontFamily: 'CustomFont',
                btnRetryBGColor: Colors.red,
                btnTextRetryColor: Colors.white,
              ),
              status: LivenessStatus.fail,
              settings: LivenessCheckSettings(
                showTryAgainButton: true,
              ),
            ),
          ),
        ),
      );

      // Should render with custom theme
      expect(find.byType(LivenessCheckScreen), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('Messages localization integration test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              messages: LivenessCheckMessages(
                title: 'Xác thực khuôn mặt',
                tryAgainButtonText: 'Thử lại',
                noFaceDetected: 'Không phát hiện khuôn mặt',
                multipleFacesDetected: 'Phát hiện nhiều khuôn mặt',
                livenessCheckPassed: 'Xác thực thành công!',
                initializingCamera: 'Đang khởi tạo camera...',
                holdStill: 'Giữ yên',
                moveCloserToCamera: 'Di chuyển gần camera hơn',
              ),
              status: LivenessStatus.fail,
              settings: LivenessCheckSettings(
                showTryAgainButton: true,
              ),
              placeholder: 'Vui lòng đặt khuôn mặt vào vòng tròn',
            ),
          ),
        ),
      );

      // Should show localized text
      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.text('Vui lòng đặt khuôn mặt vào vòng tròn'), findsOneWidget);
    });

    testWidgets('Settings configuration integration test', (WidgetTester tester) async {
      bool maxRetryReached = false;
      int maxRetryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: LivenessCheckScreen(
            config: LivenessCheckConfig(
              settings: LivenessCheckSettings(
                requiredBlinkCount: 5,
                requireSmile: true,
                showProgress: false,
                autoNavigateOnSuccess: false,
                showErrorMessage: false,
                showTryAgainButton: true,
                maxRetryAttempts: 2,
                processingTimeout: Duration(seconds: 60),
                circlePositionY: 0.5,
              ),
              status: LivenessStatus.fail,
              callbacks: LivenessCheckCallbacks(
                onMaxRetryReached: (count) {
                  maxRetryReached = true;
                  maxRetryCount = count;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LivenessCheckScreen), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}