enum LivenessCheckError {
  cameraPermissionDenied,
  cameraInitializationFailed,
  noFaceDetected,
  multipleFacesDetected,
  imageBlurry,
  faceNotClear,
  moveCloserToCamera,
  poorLighting,
  photoCaptureFailed,
  processingTimeout,
  unknownError,
}

extension LivenessCheckErrorExtension on LivenessCheckError {
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
      case LivenessCheckError.unknownError:
        return 'An unknown error occurred';
    }
  }

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
      case LivenessCheckError.unknownError:
        return 'An unknown error occurred';
    }
  }
}

class LivenessCheckErrorInfo {
  final LivenessCheckError errorType;
  final String message;
  final String? technicalDetails;
  final DateTime timestamp;

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