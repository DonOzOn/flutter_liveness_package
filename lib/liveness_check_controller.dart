import 'package:flutter/foundation.dart';

/// Controller for managing liveness check camera operations.
///
/// This controller allows external control over camera initialization,
/// disposal, and state management for the liveness check screen.
///
/// Example:
/// ```dart
/// final controller = LivenessCheckController();
///
/// LivenessCheckScreen(
///   controller: controller,
///   config: LivenessCheckConfig(...),
/// )
///
/// // Later, manually control camera
/// controller.initializeCamera();
/// controller.disposeCamera();
/// ```
class LivenessCheckController extends ChangeNotifier {
  /// Callback for initializing the camera.
  VoidCallback? _onInitializeCamera;

  /// Callback for disposing the camera.
  VoidCallback? _onDisposeCamera;

  /// Callback for resetting the liveness state.
  VoidCallback? _onResetState;

  /// Callback for pausing face detection.
  Future<void> Function()? _onPauseDetection;

  /// Callback for resuming face detection.
  Future<void> Function()? _onResumeDetection;

  /// Whether the camera is currently initialized.
  bool _isInitialized = false;

  /// Whether face detection is currently paused.
  bool _isPaused = false;

  /// Gets the current camera initialization status.
  bool get isInitialized => _isInitialized;

  /// Gets the current pause status.
  bool get isPaused => _isPaused;

  /// Internal method to set initialization status.
  /// Called by LivenessCheckScreen only.
  // ignore: use_setters_to_change_properties
  void setInitialized(bool value) {
    if (_isInitialized != value) {
      _isInitialized = value;
      notifyListeners();
    }
  }

  /// Internal method to register camera initialization callback.
  /// Called by LivenessCheckScreen only.
  void registerInitializeCallback(VoidCallback callback) {
    _onInitializeCamera = callback;
  }

  /// Internal method to register camera disposal callback.
  /// Called by LivenessCheckScreen only.
  void registerDisposeCallback(VoidCallback callback) {
    _onDisposeCamera = callback;
  }

  /// Internal method to register state reset callback.
  /// Called by LivenessCheckScreen only.
  void registerResetCallback(VoidCallback callback) {
    _onResetState = callback;
  }

  /// Internal method to register pause detection callback.
  /// Called by LivenessCheckScreen only.
  void registerPauseCallback(Future<void> Function() callback) {
    _onPauseDetection = callback;
  }

  /// Internal method to register resume detection callback.
  /// Called by LivenessCheckScreen only.
  void registerResumeCallback(Future<void> Function() callback) {
    _onResumeDetection = callback;
  }

  /// Internal method to set pause status.
  /// Called by LivenessCheckScreen only.
  // ignore: use_setters_to_change_properties
  void setPaused(bool value) {
    if (_isPaused != value) {
      _isPaused = value;
      notifyListeners();
    }
  }

  /// Initializes the camera for liveness detection.
  ///
  /// This will request camera permissions if needed and start
  /// the camera preview with face detection.
  ///
  /// Call this method when you want to manually start the camera.
  Future<void> initializeCamera() async {
    if (_onInitializeCamera != null) {
      _onInitializeCamera!();
    } else {
      debugPrint(
        'LivenessCheckController: Initialize callback not registered. '
        'Make sure the controller is attached to LivenessCheckScreen.',
      );
    }
  }

  /// Disposes the camera and releases all resources.
  ///
  /// This will stop the camera preview, face detection,
  /// and release ML Kit resources.
  ///
  /// Call this method when you want to manually stop the camera.
  Future<void> disposeCamera() async {
    if (_onDisposeCamera != null) {
      _onDisposeCamera!();
    } else {
      debugPrint(
        'LivenessCheckController: Dispose callback not registered. '
        'Make sure the controller is attached to LivenessCheckScreen.',
      );
    }
  }

  /// Resets the liveness check state.
  ///
  /// This will reset blink count, smile status, and error messages
  /// without reinitializing the camera.
  void resetState() {
    if (_onResetState != null) {
      _onResetState!();
    } else {
      debugPrint(
        'LivenessCheckController: Reset callback not registered. '
        'Make sure the controller is attached to LivenessCheckScreen.',
      );
    }
  }

  /// Pauses camera preview and face detection.
  ///
  /// This will pause the camera preview and stop processing frames
  /// for face detection. The camera remains initialized and can be
  /// resumed later.
  ///
  /// Useful when you want to temporarily stop liveness checking
  /// without disposing the camera.
  Future<void> pauseDetection() async {
    if (_onPauseDetection != null) {
      await _onPauseDetection!();
    } else {
      debugPrint(
        'LivenessCheckController: Pause callback not registered. '
        'Make sure the controller is attached to LivenessCheckScreen.',
      );
    }
  }

  /// Resumes camera preview and face detection.
  ///
  /// This will resume the camera preview and restart processing frames
  /// for face detection after being paused.
  Future<void> resumeDetection() async {
    if (_onResumeDetection != null) {
      await _onResumeDetection!();
    } else {
      debugPrint(
        'LivenessCheckController: Resume callback not registered. '
        'Make sure the controller is attached to LivenessCheckScreen.',
      );
    }
  }

  @override
  void dispose() {
    _onInitializeCamera = null;
    _onDisposeCamera = null;
    _onResetState = null;
    _onPauseDetection = null;
    _onResumeDetection = null;
    super.dispose();
  }
}
