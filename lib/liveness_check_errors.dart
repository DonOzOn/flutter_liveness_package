/// Enumeration of all possible liveness check error types.
///
/// These error types are used throughout the liveness check process to
/// categorize and handle different failure scenarios.
enum LivenessCheckError {
  /// Camera permission was denied by the user.
  cameraPermissionDenied,

  /// Failed to initialize the camera hardware.
  cameraInitializationFailed,

  /// No face detected in the camera frame.
  noFaceDetected,

  /// Multiple faces detected when only one is expected.
  multipleFacesDetected,

  /// Image quality is too blurry for detection.
  imageBlurry,

  /// Face features are not clear enough.
  faceNotClear,

  /// User needs to move closer to the camera.
  moveCloserToCamera,

  /// Lighting conditions are inadequate.
  poorLighting,

  /// Failed to capture photo after liveness check.
  photoCaptureFailed,

  /// Processing took too long and timed out.
  processingTimeout,

  /// Eyes are closed when they should be open.
  eyesClosed,

  /// Face is covered by a mask or nose/mouth not visible.
  maskDetected,

  /// Spoofing detected - fake face (photo, video, mask, etc.)
  spoofingDetected,

  /// An unknown or unexpected error occurred.
  unknownError,
}

/// Extension methods for [LivenessCheckError] enum.
extension LivenessCheckErrorExtension on LivenessCheckError {
  /// Returns the default error message for this error type.
  String getDefaultMessage() {
    switch (this) {
      case LivenessCheckError.cameraPermissionDenied:
        return 'Camera permission denied';
      case LivenessCheckError.cameraInitializationFailed:
        return 'Failed to initialize camera';
      case LivenessCheckError.noFaceDetected:
        return 'No face detected. Please position your face in the circle.';
      case LivenessCheckError.multipleFacesDetected:
        return 'Multiple faces detected. Only one person allowed.';
      case LivenessCheckError.imageBlurry:
        return 'Image too blurry. Hold device steady.';
      case LivenessCheckError.faceNotClear:
        return 'Hold still. Face features not clear.';
      case LivenessCheckError.moveCloserToCamera:
        return 'Move closer to camera or hold device steady.';
      case LivenessCheckError.poorLighting:
        return 'Poor lighting conditions.';
      case LivenessCheckError.photoCaptureFailed:
        return 'Failed to capture photo';
      case LivenessCheckError.processingTimeout:
        return 'Processing timeout. Please try again.';
      case LivenessCheckError.eyesClosed:
        return 'Please open your eyes.';
      case LivenessCheckError.maskDetected:
        return 'Please remove your mask.';
      case LivenessCheckError.spoofingDetected:
        return 'Spoofing detected. Please use a real face.';
      case LivenessCheckError.unknownError:
        return 'An unknown error occurred';
    }
  }

  /// Returns a custom error message from the provided [messages] configuration.
  ///
  /// Falls back to default messages if a custom message is not provided.
  String getCustomMessage(dynamic messages) {
    switch (this) {
      case LivenessCheckError.cameraPermissionDenied:
        return messages.cameraPermissionDenied;
      case LivenessCheckError.cameraInitializationFailed:
        return messages.failedToInitializeCamera;
      case LivenessCheckError.noFaceDetected:
        return messages.noFaceDetected;
      case LivenessCheckError.multipleFacesDetected:
        return messages.multipleFacesDetected;
      case LivenessCheckError.imageBlurry:
        return messages.imageTooBlurry;
      case LivenessCheckError.faceNotClear:
        return messages.holdStill;
      case LivenessCheckError.moveCloserToCamera:
        return messages.moveCloserToCamera;
      case LivenessCheckError.poorLighting:
        return messages.poorLighting;
      case LivenessCheckError.photoCaptureFailed:
        return messages.failedToCapture;
      case LivenessCheckError.processingTimeout:
        return 'Processing timeout. Please try again.';
      case LivenessCheckError.eyesClosed:
        return messages.eyesClosed;
      case LivenessCheckError.maskDetected:
        return messages.maskDetected;
      case LivenessCheckError.spoofingDetected:
        return messages.spoofingDetected;
      case LivenessCheckError.unknownError:
        return 'An unknown error occurred';
    }
  }
}

/// Contains detailed information about a liveness check error.
///
/// This class provides comprehensive error information including the error type,
/// user-friendly message, technical details for debugging, and timestamp.
class LivenessCheckErrorInfo {
  /// The type of error that occurred.
  final LivenessCheckError errorType;

  /// User-friendly error message.
  final String message;

  /// Optional technical details for debugging purposes.
  final String? technicalDetails;

  /// Timestamp when the error occurred.
  final DateTime timestamp;

  /// Creates a liveness check error info object.
  ///
  /// The [errorType] and [message] are required. The [technicalDetails] and
  /// [timestamp] are optional, with timestamp defaulting to the current time.
  LivenessCheckErrorInfo({
    required this.errorType,
    required this.message,
    this.technicalDetails,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    return 'LivenessCheckErrorInfo(errorType: $errorType, message: $message, timestamp: $timestamp)';
  }
}
