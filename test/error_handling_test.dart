import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

void main() {
  group('Error Handling Tests', () {
    test('LivenessCheckError should provide correct error messages', () {
      const messages = LivenessCheckMessages();

      // Test camera permission denied error
      final cameraPermissionError = LivenessCheckError.cameraPermissionDenied;
      expect(
        cameraPermissionError.getCustomMessage(messages),
        messages.cameraPermissionDenied,
      );

      // Test camera initialization failed error
      final cameraInitError = LivenessCheckError.cameraInitializationFailed;
      expect(
        cameraInitError.getCustomMessage(messages),
        messages.failedToInitializeCamera,
      );

      // Test photo capture failed error
      final captureFailedError = LivenessCheckError.photoCaptureFailed;
      expect(
        captureFailedError.getCustomMessage(messages),
        messages.failedToCapture,
      );

      // Test no face detected error
      final noFaceError = LivenessCheckError.noFaceDetected;
      expect(noFaceError.getCustomMessage(messages), messages.noFaceDetected);

      // Test multiple faces error
      final multipleFacesError = LivenessCheckError.multipleFacesDetected;
      expect(
        multipleFacesError.getCustomMessage(messages),
        messages.multipleFacesDetected,
      );

      // Test move closer error
      final moveCloserError = LivenessCheckError.moveCloserToCamera;
      expect(
        moveCloserError.getCustomMessage(messages),
        messages.moveCloserToCamera,
      );

      // Test face not clear error
      final faceNotClearError = LivenessCheckError.faceNotClear;
      expect(faceNotClearError.getCustomMessage(messages), messages.holdStill);

      // Test image blurry error
      final blurryError = LivenessCheckError.imageBlurry;
      expect(blurryError.getCustomMessage(messages), messages.imageTooBlurry);

      // Test poor lighting error
      final poorLightingError = LivenessCheckError.poorLighting;
      expect(
        poorLightingError.getCustomMessage(messages),
        messages.poorLighting,
      );
    });

    test('should handle custom error messages', () {
      const customMessages = LivenessCheckMessages(
        cameraPermissionDenied: 'Quyền truy cập camera bị từ chối',
        noFaceDetected: 'Không phát hiện khuôn mặt',
        multipleFacesDetected: 'Phát hiện nhiều khuôn mặt',
        failedToInitializeCamera: 'Không thể khởi tạo camera',
        failedToCapture: 'Không thể chụp ảnh',
        moveCloserToCamera: 'Di chuyển gần camera hơn',
        holdStill: 'Giữ yên',
        imageTooBlurry: 'Ảnh quá mờ',
        poorLighting: 'Ánh sáng kém',
      );

      final cameraPermissionError = LivenessCheckError.cameraPermissionDenied;
      expect(
        cameraPermissionError.getCustomMessage(customMessages),
        'Quyền truy cập camera bị từ chối',
      );

      final noFaceError = LivenessCheckError.noFaceDetected;
      expect(
        noFaceError.getCustomMessage(customMessages),
        'Không phát hiện khuôn mặt',
      );
    });

    test('should provide all available error types', () {
      final allErrors = LivenessCheckError.values;

      expect(allErrors, contains(LivenessCheckError.cameraPermissionDenied));
      expect(
        allErrors,
        contains(LivenessCheckError.cameraInitializationFailed),
      );
      expect(allErrors, contains(LivenessCheckError.photoCaptureFailed));
      expect(allErrors, contains(LivenessCheckError.noFaceDetected));
      expect(allErrors, contains(LivenessCheckError.multipleFacesDetected));
      expect(allErrors, contains(LivenessCheckError.moveCloserToCamera));
      expect(allErrors, contains(LivenessCheckError.faceNotClear));
      expect(allErrors, contains(LivenessCheckError.imageBlurry));
      expect(allErrors, contains(LivenessCheckError.poorLighting));
    });

    test('error callback should work correctly', () {
      String? receivedError;
      dynamic receivedErrorType;
      String? receivedMessage;

      final callbacks = LivenessCheckCallbacks(
        onError: (error) {
          receivedError = error;
        },
        onErrorWithType: (errorType, message) {
          receivedErrorType = errorType;
          receivedMessage = message;
        },
      );

      // Test simple error callback
      callbacks.onError?.call('Test error message');
      expect(receivedError, 'Test error message');

      // Test error with type callback
      callbacks.onErrorWithType?.call(
        LivenessCheckError.noFaceDetected,
        'No face detected in the frame',
      );
      expect(receivedErrorType, LivenessCheckError.noFaceDetected);
      expect(receivedMessage, 'No face detected in the frame');
    });

    test('should handle error scenarios in configuration', () {
      bool errorCalled = false;
      String? errorMessage;
      int attemptCount = 0;

      final config = LivenessCheckConfig(
        status: LivenessStatus.fail,
        settings: const LivenessCheckSettings(
          showErrorMessage: true,
          maxRetryAttempts: 3,
        ),
        callbacks: LivenessCheckCallbacks(
          onError: (error) {
            errorCalled = true;
            errorMessage = error;
          },
          onMaxRetryReached: (count) {
            attemptCount = count;
          },
        ),
      );

      expect(config.status, LivenessStatus.fail);
      expect(config.settings.showErrorMessage, true);
      expect(config.settings.maxRetryAttempts, 3);

      // Simulate error callback
      config.callbacks?.onError?.call('Camera initialization failed');
      expect(errorCalled, true);
      expect(errorMessage, 'Camera initialization failed');

      // Simulate max retry callback
      config.callbacks?.onMaxRetryReached?.call(3);
      expect(attemptCount, 3);
    });

    test('should handle different error message configurations', () {
      // Test with error messages enabled
      const configWithErrors = LivenessCheckConfig(
        settings: LivenessCheckSettings(showErrorMessage: true),
      );
      expect(configWithErrors.settings.showErrorMessage, true);

      // Test with error messages disabled
      const configWithoutErrors = LivenessCheckConfig(
        settings: LivenessCheckSettings(showErrorMessage: false),
      );
      expect(configWithoutErrors.settings.showErrorMessage, false);
    });

    test('should validate retry attempt limits', () {
      const lowRetryConfig = LivenessCheckConfig(
        settings: LivenessCheckSettings(maxRetryAttempts: 1),
      );
      expect(lowRetryConfig.settings.maxRetryAttempts, 1);

      const highRetryConfig = LivenessCheckConfig(
        settings: LivenessCheckSettings(maxRetryAttempts: 10),
      );
      expect(highRetryConfig.settings.maxRetryAttempts, 10);
    });

    test('should handle timeout configurations', () {
      const shortTimeoutConfig = LivenessCheckConfig(
        settings: LivenessCheckSettings(
          processingTimeout: Duration(seconds: 10),
        ),
      );
      expect(
        shortTimeoutConfig.settings.processingTimeout,
        const Duration(seconds: 10),
      );

      const longTimeoutConfig = LivenessCheckConfig(
        settings: LivenessCheckSettings(
          processingTimeout: Duration(minutes: 2),
        ),
      );
      expect(
        longTimeoutConfig.settings.processingTimeout,
        const Duration(minutes: 2),
      );
    });
  });

  group('Edge Cases Tests', () {
    test('should handle null callbacks gracefully', () {
      const config = LivenessCheckConfig(callbacks: null);

      expect(config.callbacks, isNull);
      // These should not throw exceptions
      config.callbacks?.onSuccess?.call();
      config.callbacks?.onError?.call('error');
      config.callbacks?.onTryAgain?.call();
    });

    test('should handle empty or null asset paths', () {
      const theme = LivenessCheckTheme(successAsset: null, failAsset: null);

      expect(theme.successAsset, isNull);
      expect(theme.failAsset, isNull);
    });

    test('should handle extreme configuration values', () {
      const extremeConfig = LivenessCheckConfig(
        settings: LivenessCheckSettings(
          requiredBlinkCount: 0,
          maxRetryAttempts: 100,
          circlePositionY: 0.0,
          processingTimeout: Duration(milliseconds: 1),
        ),
        theme: LivenessCheckTheme(
          circleSize: 0.1,
          borderWidth: 0.0,
          dashLength: 0.0,
          dashGap: 0.0,
          cameraPadding: 100.0,
        ),
      );

      expect(extremeConfig.settings.requiredBlinkCount, 0);
      expect(extremeConfig.settings.maxRetryAttempts, 100);
      expect(extremeConfig.settings.circlePositionY, 0.0);
      expect(extremeConfig.theme.circleSize, 0.1);
      expect(extremeConfig.theme.borderWidth, 0.0);
    });

    test('should handle very long strings', () {
      final longString = 'A' * 1000;

      final messages = LivenessCheckMessages(
        title: longString,
        noFaceDetected: longString,
      );

      expect(messages.title, longString);
      expect(messages.noFaceDetected, longString);
    });
  });
}
