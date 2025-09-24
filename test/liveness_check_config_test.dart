import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

void main() {
  group('LivenessCheckConfig Tests', () {
    test('should create config with default values', () {
      const config = LivenessCheckConfig();

      expect(config.theme, isA<LivenessCheckTheme>());
      expect(config.messages, isA<LivenessCheckMessages>());
      expect(config.settings, isA<LivenessCheckSettings>());
      expect(config.status, LivenessStatus.init);
      expect(config.showLoading, false);
      expect(config.placeholder, 'Please smile or blink eye 3 time');
      expect(config.customHeader, isNull);
      expect(config.customBottomWidget, isNull);
      expect(config.customLoadingWidget, isNull);
    });

    test('should create config with custom values', () {
      final customHeader = Container(child: Text('Custom Header'));
      final customBottomWidget = Container(child: Text('Custom Bottom'));
      final customLoadingWidget = Container(child: Text('Loading...'));

      final config = LivenessCheckConfig(
        customHeader: customHeader,
        customBottomWidget: customBottomWidget,
        customLoadingWidget: customLoadingWidget,
        status: LivenessStatus.success,
        showLoading: true,
        placeholder: 'Custom placeholder text',
      );

      expect(config.customHeader, equals(customHeader));
      expect(config.customBottomWidget, equals(customBottomWidget));
      expect(config.customLoadingWidget, equals(customLoadingWidget));
      expect(config.status, LivenessStatus.success);
      expect(config.showLoading, true);
      expect(config.placeholder, 'Custom placeholder text');
    });
  });

  group('LivenessCheckTheme Tests', () {
    test('should create theme with default values', () {
      const theme = LivenessCheckTheme();

      expect(theme.backgroundColor, Colors.white);
      expect(theme.primaryColor, Colors.blue);
      expect(theme.successColor, Colors.green);
      expect(theme.errorColor, Colors.red);
      expect(theme.warningColor, Colors.orange);
      expect(theme.borderColor, Colors.blue);
      expect(theme.textColor, Colors.black);
      expect(theme.circleSize, 0.65);
      expect(theme.borderWidth, 4.0);
      expect(theme.borderStyle, CircleBorderStyle.solid);
      expect(theme.dashLength, 8.0);
      expect(theme.dashGap, 8.0);
      expect(theme.cameraPadding, 0.0);
      expect(theme.btnRetryBGColor, Colors.blue);
      expect(theme.btnTextRetryColor, Colors.white);
    });

    test('should create theme with custom values', () {
      const theme = LivenessCheckTheme(
        backgroundColor: Colors.black,
        primaryColor: Colors.purple,
        successColor: Colors.teal,
        errorColor: Colors.orange,
        borderStyle: CircleBorderStyle.dashed,
        dashLength: 12.0,
        dashGap: 6.0,
        cameraPadding: 10.0,
        circleSize: 0.8,
        borderWidth: 3.0,
        fontFamily: 'CustomFont',
        btnRetryBGColor: Colors.red,
        btnTextRetryColor: Colors.yellow,
      );

      expect(theme.backgroundColor, Colors.black);
      expect(theme.primaryColor, Colors.purple);
      expect(theme.successColor, Colors.teal);
      expect(theme.errorColor, Colors.orange);
      expect(theme.borderStyle, CircleBorderStyle.dashed);
      expect(theme.dashLength, 12.0);
      expect(theme.dashGap, 6.0);
      expect(theme.cameraPadding, 10.0);
      expect(theme.circleSize, 0.8);
      expect(theme.borderWidth, 3.0);
      expect(theme.fontFamily, 'CustomFont');
      expect(theme.btnRetryBGColor, Colors.red);
      expect(theme.btnTextRetryColor, Colors.yellow);
    });

    test('should create theme copy with updated values', () {
      const originalTheme = LivenessCheckTheme();
      final copiedTheme = originalTheme.copyWith(
        primaryColor: Colors.purple,
        borderStyle: CircleBorderStyle.dashed,
        circleSize: 0.9,
      );

      expect(copiedTheme.primaryColor, Colors.purple);
      expect(copiedTheme.borderStyle, CircleBorderStyle.dashed);
      expect(copiedTheme.circleSize, 0.9);
      // Other values should remain the same
      expect(copiedTheme.backgroundColor, Colors.white);
      expect(copiedTheme.successColor, Colors.green);
      expect(copiedTheme.borderWidth, 4.0);
    });
  });

  group('LivenessCheckSettings Tests', () {
    test('should create settings with default values', () {
      const settings = LivenessCheckSettings();

      expect(settings.requiredBlinkCount, 3);
      expect(settings.requireSmile, false);
      expect(settings.showProgress, true);
      expect(settings.autoNavigateOnSuccess, true);
      expect(settings.showErrorMessage, true);
      expect(settings.showTryAgainButton, true);
      expect(settings.maxRetryAttempts, 3);
      expect(settings.processingTimeout, const Duration(seconds: 30));
      expect(settings.circlePositionY, 0.38);
    });

    test('should create settings with custom values', () {
      const settings = LivenessCheckSettings(
        requiredBlinkCount: 5,
        requireSmile: true,
        showProgress: false,
        autoNavigateOnSuccess: false,
        showErrorMessage: false,
        showTryAgainButton: false,
        maxRetryAttempts: 5,
        processingTimeout: Duration(seconds: 60),
        circlePositionY: 0.5,
      );

      expect(settings.requiredBlinkCount, 5);
      expect(settings.requireSmile, true);
      expect(settings.showProgress, false);
      expect(settings.autoNavigateOnSuccess, false);
      expect(settings.showErrorMessage, false);
      expect(settings.showTryAgainButton, false);
      expect(settings.maxRetryAttempts, 5);
      expect(settings.processingTimeout, const Duration(seconds: 60));
      expect(settings.circlePositionY, 0.5);
    });
  });

  group('LivenessCheckMessages Tests', () {
    test('should create messages with default values', () {
      const messages = LivenessCheckMessages();

      expect(messages.title, 'Liveness Check');
      expect(messages.tryAgainButtonText, 'Try Again');
      expect(messages.initializingCamera, 'Initializing camera...');
      expect(messages.noFaceDetected, 'No face detected. Please position your face in the circle.');
      expect(messages.multipleFacesDetected, 'Multiple faces detected. Please ensure only one person is visible.');
      expect(messages.livenessCheckPassed, 'Liveness check passed! Taking photo...');
    });

    test('should create messages with custom values', () {
      const messages = LivenessCheckMessages(
        title: 'Xác thực khuôn mặt',
        tryAgainButtonText: 'Thử lại',
        noFaceDetected: 'Không phát hiện khuôn mặt',
        multipleFacesDetected: 'Phát hiện nhiều khuôn mặt',
        livenessCheckPassed: 'Xác thực thành công!',
      );

      expect(messages.title, 'Xác thực khuôn mặt');
      expect(messages.tryAgainButtonText, 'Thử lại');
      expect(messages.noFaceDetected, 'Không phát hiện khuôn mặt');
      expect(messages.multipleFacesDetected, 'Phát hiện nhiều khuôn mặt');
      expect(messages.livenessCheckPassed, 'Xác thực thành công!');
    });
  });

  group('LivenessCheckCallbacks Tests', () {
    test('should create callbacks with null values by default', () {
      const callbacks = LivenessCheckCallbacks();

      expect(callbacks.onSuccess, isNull);
      expect(callbacks.onError, isNull);
      expect(callbacks.onErrorWithType, isNull);
      expect(callbacks.onCancel, isNull);
      expect(callbacks.onPhotoTaken, isNull);
      expect(callbacks.onProgressUpdate, isNull);
      expect(callbacks.onTryAgain, isNull);
      expect(callbacks.onMaxRetryReached, isNull);
    });

    test('should create callbacks with custom functions', () {
      bool successCalled = false;
      String? errorMessage;
      bool tryAgainCalled = false;
      int? maxRetryCount;

      final callbacks = LivenessCheckCallbacks(
        onSuccess: () => successCalled = true,
        onError: (error) => errorMessage = error,
        onTryAgain: () => tryAgainCalled = true,
        onMaxRetryReached: (count) => maxRetryCount = count,
      );

      expect(callbacks.onSuccess, isNotNull);
      expect(callbacks.onError, isNotNull);
      expect(callbacks.onTryAgain, isNotNull);
      expect(callbacks.onMaxRetryReached, isNotNull);

      // Test callback execution
      callbacks.onSuccess!();
      expect(successCalled, true);

      callbacks.onError!('Test error');
      expect(errorMessage, 'Test error');

      callbacks.onTryAgain!();
      expect(tryAgainCalled, true);

      callbacks.onMaxRetryReached!(5);
      expect(maxRetryCount, 5);
    });
  });

  group('Enums Tests', () {
    test('CircleBorderStyle enum should have correct values', () {
      expect(CircleBorderStyle.values, [
        CircleBorderStyle.solid,
        CircleBorderStyle.dashed,
      ]);
    });

    test('LivenessStatus enum should have correct values', () {
      expect(LivenessStatus.values, [
        LivenessStatus.init,
        LivenessStatus.success,
        LivenessStatus.fail,
      ]);
    });
  });
}