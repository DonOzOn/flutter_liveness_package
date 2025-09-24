import 'package:flutter/material.dart';

class LivenessCheckConfig {
  final Widget? customBottomWidget;
  final LivenessCheckTheme theme;
  final LivenessCheckCallbacks? callbacks;
  final LivenessCheckMessages messages;
  final LivenessCheckSettings settings;
  final String? placeholder;
  final LivenessStatus status;
  final bool showLoading;
  final Widget? customLoadingWidget;
  final AppBarConfig appBarConfig;

  const LivenessCheckConfig({
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

enum CircleBorderStyle { solid, dashed }

enum LivenessStatus { init, success, fail }

class AppBarConfig {
  final String? title;
  final TextStyle? titleStyle;
  final Color? backgroundColor;
  final double? elevation;
  final Widget? customBackIcon;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final bool showBackButton;

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

class LivenessCheckTheme {
  final Color backgroundColor;
  final Color primaryColor;
  final Color successColor;
  final Color errorColor;
  final Color warningColor;
  final Color borderColor;
  final Color textColor;
  final Color? overlayColor;
  final Color? btnRetryBGColor;
  final Color? btnTextRetryColor;
  final double circleSize;
  final double borderWidth;
  final CircleBorderStyle borderStyle;
  final double dashLength;
  final double dashGap;
  final double cameraPadding;
  final String? successAsset;
  final String? failAsset;
  final String? fontFamily;
  final TextStyle? titleTextStyle;
  final TextStyle? messageTextStyle;
  final TextStyle? errorTextStyle;
  final TextStyle? successTextStyle;

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

class LivenessCheckCallbacks {
  final VoidCallback? onSuccess;
  final Function(String error)? onError;
  final Function(dynamic errorType, String message)? onErrorWithType;
  final VoidCallback? onCancel;
  final Function(String imagePath)? onPhotoTaken;
  final Function(int blinkCount, bool isSmiling)? onProgressUpdate;
  final VoidCallback? onTryAgain;
  final Function(int attemptCount)? onMaxRetryReached;

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

class LivenessCheckMessages {
  final String title;
  final String initializingCamera;
  final String noFaceDetected;
  final String multipleFacesDetected;
  final String moveCloserToCamera;
  final String holdStill;
  final String imageTooBlurry;
  final String poorLighting;
  final String livenessCheckPassed;
  final String takingPhoto;
  final String failedToCapture;
  final String cameraPermissionDenied;
  final String failedToInitializeCamera;
  final String tryAgainButtonText;

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
  });
}

class LivenessCheckSettings {
  final int requiredBlinkCount;
  final bool requireSmile;
  final bool showProgress;
  final bool autoNavigateOnSuccess;
  final bool showErrorMessage;
  final bool showTryAgainButton;
  final int maxRetryAttempts;
  final Duration processingTimeout;
  final double circlePositionY;

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
