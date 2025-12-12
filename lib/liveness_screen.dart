import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/liveness_check_controller.dart';
import 'package:flutter_liveness_check/liveness_check_screen.dart';

import 'liveness_check_config.dart';

class LivenessScreen extends StatefulWidget {
  const LivenessScreen({super.key});

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen> {
  final LivenessCheckController _controller = LivenessCheckController();
  String? capturedImagePath;
  String? capturedImageBase64;
  Uint8List? thermalImageBytes;

  /// Convert image file to base64 string
  Future<String> convertImageToBase64(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      rethrow;
    }
  }

  /// Handle successful photo capture
  Future<void> _onCaptureSuccess(String imagePath, bool isReal) async {
    setState(() {
      capturedImagePath = imagePath;
    });

    try {
      // Convert to base64
      final base64Image = await convertImageToBase64(imagePath);

      setState(() {
        capturedImageBase64 = base64Image;
      });

      debugPrint('Image converted to base64 successfully');
      _controller.pauseDetection();
      // Here you can send the base64Image to your backend
      // For example: await uploadToServer(base64Image);
    } catch (e) {
      debugPrint('Error processing captured image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle liveness check success
  void _onSuccess() {
    debugPrint('Liveness check passed!');
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Liveness check passed successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Handle liveness check error
  void _onError(String error) {
    debugPrint('Liveness check error: $error');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Handle cancellation
  void _onCancel() {
    debugPrint('Liveness check cancelled');
    Navigator.of(context).pop();
  }

  /// Handle max retry reached
  void _onMaxRetryReached(int attemptCount) {
    debugPrint('Max retry attempts reached: $attemptCount');
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Maximum retry attempts ($attemptCount) reached. Please try again later.',
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      controller: _controller,
      config: LivenessCheckConfig(
        // Callbacks configuration
        callbacks: LivenessCheckCallbacks(
          onSuccess: _onSuccess,
          onError: _onError,
          onCancel: _onCancel,
          onPhotoTaken: _onCaptureSuccess,
          onMaxRetryReached: _onMaxRetryReached,
          onProgressUpdate: (blinkCount, isSmiling) {
            debugPrint('Progress - Blinks: $blinkCount, Smiling: $isSmiling');
          },
        ),

        // Theme customization
        theme: LivenessCheckTheme(
          primaryColor: Colors.deepPurple,
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          borderColor: Colors.deepPurple,
          successColor: Colors.green,
          errorColor: Colors.red,
          warningColor: Colors.orange,
          overlayColor: Colors.white.withValues(alpha: 0.9),
          circleSize: 0.65, // 65% of screen width
          borderWidth: 4.0,
          borderStyle: CircleBorderStyle.solid,
          cameraPadding: 8.0,
          // Button styling
          btnRetryBGColor: Colors.deepPurple,
          btnTextRetryColor: Colors.white,
          btnRetryHeight: 50.0,
          btnRetryBorderRadius: 8.0,
          // Text styles
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          messageTextStyle: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          errorTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
          successTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),

        // Messages customization
        messages: const LivenessCheckMessages(
          title: 'Face Verification',
          initializingCamera: 'Initializing camera...',
          noFaceDetected: 'Please position your face in the circle',
          multipleFacesDetected: 'Only one person allowed',
          moveCloserToCamera: 'Move closer to the camera',
          holdStill: 'Hold still...',
          imageTooBlurry: 'Image too blurry. Please hold device steady',
          poorLighting: 'Poor lighting. Please move to a well-lit area',
          livenessCheckPassed: 'Verification successful! Taking photo...',
          takingPhoto: 'Taking photo...',
          failedToCapture: 'Failed to capture photo',
          cameraPermissionDenied: 'Camera permission denied',
          failedToInitializeCamera: 'Failed to initialize camera',
          tryAgainButtonText: 'Try Again',
          permissionDialogConfig: PermissionDialogConfig(
            title: 'Camera Permission Required',
            message:
                'Camera permission is required for face verification. Please enable it in settings.',
            cancelButtonText: 'Cancel',
            settingsButtonText: 'Open Settings',
          ),
        ),

        // Behavior settings
        settings: const LivenessCheckSettings(
          enableBlinkDetection: false,
          requiredBlinkCount: 3,
          enableSmileDetection: false,
          enableEyesClosedCheck: true,
          showProgress: true,
          autoNavigateOnSuccess: false, // We handle navigation in callbacks
          showErrorMessage: true,
          showTryAgainButton: true,
          maxRetryAttempts: 3,
          processingTimeout: Duration(seconds: 30),
          circlePositionY: 0.38, // Position circle at 38% from top
        ),

        // Camera settings (using default values)
        cameraSettings: const CameraSettings(enableAudio: false),

        // App bar configuration
        appBarConfig: const AppBarConfig(
          title: 'Liveness Check',
          showBackButton: true,
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1.0,
        ),

        // Initial status
        status: LivenessStatus.init,
      ),
    );
  }
}
