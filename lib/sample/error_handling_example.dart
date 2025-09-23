import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

class ErrorHandlingExample extends StatelessWidget {
  const ErrorHandlingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Handling Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _showBasicErrorHandling(context),
              child: const Text('Basic Error Handling'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAdvancedErrorHandling(context),
              child: const Text('Advanced Error Handling with Types'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCustomErrorMessages(context),
              child: const Text('Custom Error Messages'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBasicErrorHandling(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessCheckScreen(
          config: LivenessCheckConfig(
            callbacks: LivenessCheckCallbacks(
              onError: (String errorMessage) {
                // Basic error handling - just show the message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              onSuccess: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Liveness check successful!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showAdvancedErrorHandling(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessCheckScreen(
          config: LivenessCheckConfig(
            callbacks: LivenessCheckCallbacks(
              // New typed error callback
              onErrorWithType: (dynamic errorType, String message) {
                _handleTypedError(context, errorType, message);
              },
              // Backward compatibility
              onError: (String errorMessage) {
                print('Legacy error callback: $errorMessage');
              },
              onSuccess: () {
                _showSuccessDialog(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomErrorMessages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessCheckScreen(
          config: LivenessCheckConfig(
            // Custom error messages
            messages: const LivenessCheckMessages(
              title: 'Face Verification',
              cameraPermissionDenied: 'We need camera access to verify your identity',
              noFaceDetected: 'Please position your face in the verification area',
              multipleFacesDetected: 'Please ensure only you are visible in the frame',
              imageTooBlurry: 'Please hold your device steady for a clear image',
              holdStill: 'Please keep your head still for verification',
              moveCloserToCamera: 'Please move closer or ensure good lighting',
              poorLighting: 'Please move to a well-lit area',
              failedToCapture: 'Photo capture failed, please try again',
              livenessCheckPassed: 'Verification complete! Processing...',
            ),
            callbacks: LivenessCheckCallbacks(
              onErrorWithType: (dynamic errorType, String message) {
                _handleCustomError(context, errorType, message);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleTypedError(BuildContext context, dynamic errorType, String message) {
    Color errorColor;
    IconData errorIcon;
    String actionText = 'Try Again';
    VoidCallback? action;

    // Handle different error types with specific UI and actions
    switch (errorType) {
      case LivenessCheckError.cameraPermissionDenied:
        errorColor = Colors.orange;
        errorIcon = Icons.camera_alt_outlined;
        actionText = 'Open Settings';
        action = () => _openAppSettings();
        break;

      case LivenessCheckError.cameraInitializationFailed:
        errorColor = Colors.red;
        errorIcon = Icons.error_outline;
        actionText = 'Restart App';
        action = () => _restartApp(context);
        break;

      case LivenessCheckError.noFaceDetected:
        errorColor = Colors.blue;
        errorIcon = Icons.face_outlined;
        actionText = 'Position Face';
        action = () => Navigator.pop(context);
        break;

      case LivenessCheckError.multipleFacesDetected:
        errorColor = Colors.amber;
        errorIcon = Icons.groups_outlined;
        actionText = 'Ensure Privacy';
        action = () => Navigator.pop(context);
        break;

      case LivenessCheckError.imageBlurry:
      case LivenessCheckError.faceNotClear:
      case LivenessCheckError.moveCloserToCamera:
        errorColor = Colors.purple;
        errorIcon = Icons.blur_on_outlined;
        actionText = 'Improve Quality';
        action = () => _showQualityTips(context);
        break;

      case LivenessCheckError.poorLighting:
        errorColor = Colors.yellow.shade700;
        errorIcon = Icons.lightbulb_outline;
        actionText = 'Lighting Tips';
        action = () => _showLightingTips(context);
        break;

      case LivenessCheckError.photoCaptureFailed:
        errorColor = Colors.red;
        errorIcon = Icons.photo_camera_outlined;
        action = () => Navigator.pop(context);
        break;

      default:
        errorColor = Colors.grey;
        errorIcon = Icons.error_outline;
        action = () => Navigator.pop(context);
    }

    _showErrorDialog(context, message, errorColor, errorIcon, actionText, action);
  }

  void _handleCustomError(BuildContext context, dynamic errorType, String message) {
    // Custom error handling with analytics tracking
    _logErrorToAnalytics(errorType, message);

    // Show user-friendly error with custom styling
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Verification Issue'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Text(
              'Error Type: ${errorType.toString().split('.').last}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _retryWithBetterInstructions(context, errorType);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
    String actionText,
    VoidCallback? action,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            const Text('Verification Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              action?.call();
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Verification Successful!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Your identity has been verified successfully.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _openAppSettings() {
    // Implementation to open app settings
    print('Opening app settings for camera permission');
  }

  void _restartApp(BuildContext context) {
    // Implementation to restart app
    print('Restarting app due to camera initialization failure');
  }

  void _showQualityTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Quality Tips'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Hold your device steady'),
            Text('• Ensure your face fills most of the circle'),
            Text('• Remove glasses if they cause glare'),
            Text('• Keep your head still during capture'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showLightingTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lighting Tips'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Face a window or light source'),
            Text('• Avoid backlighting'),
            Text('• Turn on room lights if needed'),
            Text('• Avoid shadows on your face'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _logErrorToAnalytics(dynamic errorType, String message) {
    // Log error to your analytics service
    print('Analytics: Error - Type: $errorType, Message: $message');
  }

  void _retryWithBetterInstructions(BuildContext context, dynamic errorType) {
    // Show better instructions based on error type before retrying
    print('Showing improved instructions for error type: $errorType');
  }
}

// Example of creating a custom error handler service
class LivenessErrorHandler {
  static void handleError(
    BuildContext context,
    dynamic errorType,
    String message, {
    bool showDialog = true,
    bool logToAnalytics = true,
    VoidCallback? onRetry,
  }) {
    if (logToAnalytics) {
      _logError(errorType, message);
    }

    if (showDialog) {
      _showErrorUI(context, errorType, message, onRetry);
    }
  }

  static void _logError(dynamic errorType, String message) {
    // Implement your error logging here
    print('Error logged: $errorType - $message');
  }

  static void _showErrorUI(
    BuildContext context,
    dynamic errorType,
    String message,
    VoidCallback? onRetry,
  ) {
    // Implement your error UI here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}