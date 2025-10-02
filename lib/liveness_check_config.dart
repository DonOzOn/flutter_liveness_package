import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Main configuration class for the liveness check screen.
///
/// This class contains all customization options including theme, callbacks,
/// messages, settings, and UI components.
///
/// Example:
/// ```dart
/// LivenessCheckConfig(
///   theme: LivenessCheckTheme(primaryColor: Colors.blue),
///   callbacks: LivenessCheckCallbacks(
///     onSuccess: () => print('Success'),
///   ),
///   messages: LivenessCheckMessages(
///     title: 'Verify Your Identity',
///   ),
/// )
/// ```
class LivenessCheckConfig {
  /// Custom widget to display at the bottom of the screen.
  final Widget? customBottomWidget;

  /// Theme configuration for visual customization.
  final LivenessCheckTheme theme;

  /// Callbacks for handling events.
  final LivenessCheckCallbacks? callbacks;

  /// Customizable text messages.
  final LivenessCheckMessages messages;

  /// Behavior settings for the liveness check.
  final LivenessCheckSettings settings;

  /// Camera-specific settings.
  final CameraSettings? cameraSettings;

  /// Placeholder text shown during liveness check.
  final String? placeholder;

  /// Current status of the liveness check (init, success, fail).
  final LivenessStatus status;

  /// Whether to show a loading overlay.
  final bool showLoading;

  /// Custom loading widget to replace the default spinner.
  final Widget? customLoadingWidget;

  /// AppBar configuration.
  final AppBarConfig appBarConfig;

  /// Creates a liveness check configuration.
  const LivenessCheckConfig({
    this.cameraSettings = const CameraSettings(),
    this.customBottomWidget,
    this.theme = const LivenessCheckTheme(),
    this.callbacks,
    this.messages = const LivenessCheckMessages(),
    this.settings = const LivenessCheckSettings(),
    this.placeholder = "Please smile or blink eye 3 time",
    this.status = LivenessStatus.init,
    this.showLoading = false,
    this.customLoadingWidget,
    this.appBarConfig = const AppBarConfig(),
  });
}

/// Camera-specific configuration settings.
class CameraSettings {
  /// Camera resolution preset.
  final ResolutionPreset? resolutionPreset;

  /// Whether to enable audio recording.
  final bool? enableAudio;

  /// Image format group for camera output.
  final ImageFormatGroup? imageFormatGroup;

  /// Creates camera settings.
  const CameraSettings({
    this.resolutionPreset = ResolutionPreset.high,
    this.enableAudio = false,
    this.imageFormatGroup,
  });
}

/// Style options for the circular border.
enum CircleBorderStyle {
  /// Solid circular border.
  solid,

  /// Dashed circular border.
  dashed
}

/// Status states for the liveness check.
enum LivenessStatus {
  /// Initial state - showing camera for liveness detection.
  init,

  /// Success state - showing success indicator.
  success,

  /// Failure state - showing error with retry option.
  fail
}

/// Configuration for the app bar.
class AppBarConfig {
  /// Title text for the app bar.
  final String? title;

  /// Text style for the title.
  final TextStyle? titleStyle;

  /// Background color of the app bar.
  final Color? backgroundColor;

  /// Elevation of the app bar.
  final double? elevation;

  /// Custom back button widget.
  final Widget? customBackIcon;

  /// Whether to center the title.
  final bool centerTitle;

  /// Whether to automatically show leading widget.
  final bool automaticallyImplyLeading;

  /// Whether to show the back button.
  final bool showBackButton;

  /// Creates an app bar configuration.
  const AppBarConfig({
    this.title,
    this.titleStyle,
    this.backgroundColor,
    this.elevation = 0,
    this.customBackIcon,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.showBackButton = true,
  });
}

/// Theme configuration for visual customization of the liveness check screen.
class LivenessCheckTheme {
  /// Background color of the screen.
  final Color backgroundColor;

  /// Primary color for UI elements.
  final Color primaryColor;

  /// Color for success indicators.
  final Color successColor;

  /// Color for error indicators.
  final Color errorColor;

  /// Color for warning indicators.
  final Color warningColor;

  /// Color of the circular border.
  final Color borderColor;

  /// Default text color.
  final Color textColor;

  /// Overlay color covering the camera preview.
  final Color? overlayColor;

  /// Background color of the retry button.
  final Color? btnRetryBGColor;

  /// Text color of the retry button.
  final Color? btnTextRetryColor;

  /// Size of the circular preview (0.0 to 1.0 of screen width).
  final double circleSize;

  /// Width of the circular border.
  final double borderWidth;

  /// Style of the circular border (solid or dashed).
  final CircleBorderStyle borderStyle;

  /// Length of each dash segment (when using dashed border).
  final double dashLength;

  /// Gap between dash segments (when using dashed border).
  final double dashGap;

  /// Padding between border and camera preview.
  final double cameraPadding;

  /// Asset path for success indicator image.
  final String? successAsset;

  /// Asset path for failure indicator image.
  final String? failAsset;

  /// Font family for all text elements.
  final String? fontFamily;

  /// Text style for title.
  final TextStyle? titleTextStyle;

  /// Text style for messages.
  final TextStyle? messageTextStyle;

  /// Text style for error messages.
  final TextStyle? errorTextStyle;

  /// Text style for success messages.
  final TextStyle? successTextStyle;

  /// Creates a liveness check theme.
  const LivenessCheckTheme({
    this.backgroundColor = Colors.white,
    this.btnRetryBGColor = Colors.blue,
    this.btnTextRetryColor = Colors.white,
    this.primaryColor = Colors.blue,
    this.successColor = Colors.green,
    this.errorColor = Colors.red,
    this.warningColor = Colors.orange,
    this.borderColor = Colors.blue,
    this.textColor = Colors.black,
    this.overlayColor = Colors.white,
    this.circleSize = 0.65,
    this.borderWidth = 4,
    this.borderStyle = CircleBorderStyle.solid,
    this.dashLength = 8.0,
    this.dashGap = 8.0,
    this.cameraPadding = 0.0,
    this.successAsset,
    this.failAsset,
    this.fontFamily,
    this.titleTextStyle,
    this.messageTextStyle,
    this.errorTextStyle,
    this.successTextStyle,
  });

  /// Creates a copy of this theme with the given fields replaced.
  LivenessCheckTheme copyWith({
    Color? backgroundColor,
    Color? primaryColor,
    Color? btnRetryBGColor,
    Color? btnTextRetryColor,
    Color? successColor,
    Color? errorColor,
    Color? warningColor,
    Color? borderColor,
    Color? textColor,
    Color? overlayColor,
    double? circleSize,
    double? borderWidth,
    CircleBorderStyle? borderStyle,
    double? dashLength,
    double? dashGap,
    double? cameraPadding,
    String? successAsset,
    String? failAsset,
    String? fontFamily,
    TextStyle? titleTextStyle,
    TextStyle? messageTextStyle,
    TextStyle? errorTextStyle,
    TextStyle? successTextStyle,
  }) {
    return LivenessCheckTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      btnRetryBGColor: btnRetryBGColor ?? this.btnRetryBGColor,
      btnTextRetryColor: btnTextRetryColor ?? this.btnTextRetryColor,
      warningColor: warningColor ?? this.warningColor,
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      overlayColor: overlayColor ?? this.overlayColor,
      circleSize: circleSize ?? this.circleSize,
      borderWidth: borderWidth ?? this.borderWidth,
      borderStyle: borderStyle ?? this.borderStyle,
      dashLength: dashLength ?? this.dashLength,
      dashGap: dashGap ?? this.dashGap,
      cameraPadding: cameraPadding ?? this.cameraPadding,
      successAsset: successAsset ?? this.successAsset,
      failAsset: failAsset ?? this.failAsset,
      fontFamily: fontFamily ?? this.fontFamily,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      messageTextStyle: messageTextStyle ?? this.messageTextStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      successTextStyle: successTextStyle ?? this.successTextStyle,
    );
  }
}

/// Callback functions for handling liveness check events.
class LivenessCheckCallbacks {
  /// Called when liveness check passes successfully.
  final VoidCallback? onSuccess;

  /// Called when an error occurs with error message.
  final Function(String error)? onError;

  /// Called when an error occurs with error type and message.
  final Function(dynamic errorType, String message)? onErrorWithType;

  /// Called when user cancels the liveness check.
  final VoidCallback? onCancel;

  /// Called when photo is captured with the image path.
  final Function(String imagePath)? onPhotoTaken;

  /// Called during liveness check with progress updates.
  final Function(int blinkCount, bool isSmiling)? onProgressUpdate;

  /// Called when user taps the try again button.
  final VoidCallback? onTryAgain;

  /// Called when maximum retry attempts are reached.
  final Function(int attemptCount)? onMaxRetryReached;

  /// Creates liveness check callbacks.
  const LivenessCheckCallbacks({
    this.onSuccess,
    this.onError,
    this.onErrorWithType,
    this.onCancel,
    this.onPhotoTaken,
    this.onProgressUpdate,
    this.onTryAgain,
    this.onMaxRetryReached,
  });
}

/// Customizable text messages for the liveness check screen.
class LivenessCheckMessages {
  /// Title of the screen.
  final String title;

  /// Message shown while initializing camera.
  final String initializingCamera;

  /// Message shown when no face is detected.
  final String noFaceDetected;

  /// Message shown when multiple faces are detected.
  final String multipleFacesDetected;

  /// Message shown when user needs to move closer.
  final String moveCloserToCamera;

  /// Message shown when user needs to hold still.
  final String holdStill;

  /// Message shown when image is too blurry.
  final String imageTooBlurry;

  /// Message shown when lighting is poor.
  final String poorLighting;

  /// Message shown when liveness check passes.
  final String livenessCheckPassed;

  /// Message shown while taking photo.
  final String takingPhoto;

  /// Message shown when photo capture fails.
  final String failedToCapture;

  /// Message shown when camera permission is denied.
  final String cameraPermissionDenied;

  /// Message shown when camera initialization fails.
  final String failedToInitializeCamera;

  /// Text for the try again button.
  final String tryAgainButtonText;

  /// Configuration for the permission dialog.
  final PermissionDialogConfig permissionDialogConfig;

  /// Creates liveness check messages.
  const LivenessCheckMessages({
    this.title = 'Liveness Check',
    this.initializingCamera = 'Initializing camera...',
    this.noFaceDetected =
        'No face detected. Please position your face in the circle.',
    this.multipleFacesDetected =
        'Multiple faces detected. Only one person allowed.',
    this.moveCloserToCamera = 'Move closer to camera or hold device steady.',
    this.holdStill = 'Hold still. Face features not clear.',
    this.imageTooBlurry = 'Image too blurry. Hold device steady.',
    this.poorLighting = 'Poor lighting conditions.',
    this.livenessCheckPassed = 'Liveness check passed! Taking photo...',
    this.takingPhoto = 'Taking photo...',
    this.failedToCapture = 'Failed to capture photo',
    this.cameraPermissionDenied = 'Camera permission denied',
    this.failedToInitializeCamera = 'Failed to initialize camera',
    this.tryAgainButtonText = 'Try Again',
    this.permissionDialogConfig = const PermissionDialogConfig(),
  });
}

/// Configuration for the camera permission dialog.
///
/// This dialog appears when camera permission is permanently denied,
/// offering users the option to navigate to settings.
class PermissionDialogConfig {
  /// Title of the permission dialog.
  final String title;

  /// Message explaining why permission is needed.
  final String message;

  /// Text for the cancel button.
  final String cancelButtonText;

  /// Text for the settings button.
  final String settingsButtonText;

  /// Creates a permission dialog configuration.
  const PermissionDialogConfig({
    this.title = 'Camera Permission Required',
    this.message = 'Camera permission is required for liveness check. Please enable it in settings.',
    this.cancelButtonText = 'Cancel',
    this.settingsButtonText = 'Open Settings',
  });
}

/// Behavior settings for the liveness check.
class LivenessCheckSettings {
  /// Number of blinks required to pass the liveness check.
  final int requiredBlinkCount;

  /// Whether a smile is required to pass the liveness check.
  final bool requireSmile;

  /// Whether to show progress indicators during the check.
  final bool showProgress;

  /// Whether to automatically navigate on successful verification.
  final bool autoNavigateOnSuccess;

  /// Whether to show error messages to the user.
  final bool showErrorMessage;

  /// Whether to show the try again button on failure.
  final bool showTryAgainButton;

  /// Maximum number of retry attempts allowed.
  final int maxRetryAttempts;

  /// Timeout duration for processing.
  final Duration processingTimeout;

  /// Vertical position of the circle (0.0 to 1.0).
  final double circlePositionY;

  /// Creates liveness check settings.
  const LivenessCheckSettings({
    this.requiredBlinkCount = 3,
    this.requireSmile = false,
    this.showProgress = true,
    this.autoNavigateOnSuccess = true,
    this.showErrorMessage = true,
    this.showTryAgainButton = true,
    this.maxRetryAttempts = 3,
    this.processingTimeout = const Duration(seconds: 30),
    this.circlePositionY = 0.38,
  });
}
