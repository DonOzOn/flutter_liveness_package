import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_liveness_check/enhence_light_checker.dart';
import 'package:flutter_liveness_check/liveness_check_config.dart';
import 'package:flutter_liveness_check/liveness_check_controller.dart';
import 'package:flutter_liveness_check/liveness_check_errors.dart';
import 'package:flutter_liveness_check/widget/dashed_circle_painter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

/// A screen that performs real-time liveness detection using face recognition.
///
/// This screen uses the device's front camera to detect facial features and
/// verify that the user is a live person through eye blinking and smiling gestures.
///
/// Features:
/// - Real-time face detection with ML Kit
/// - Blur and lighting quality analysis
/// - Eye blink detection with head movement filtering
/// - Smile detection requiring visible teeth
/// - Circular camera preview with overlay
/// - Enhanced error messaging with technical details
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const LivenessCheckScreen()),
/// );
/// ```
class LivenessCheckScreen extends StatefulWidget {
  /// Configuration for the liveness check screen.
  final LivenessCheckConfig config;

  /// Optional controller for manual camera control.
  final LivenessCheckController? controller;

  const LivenessCheckScreen({
    super.key,
    this.config = const LivenessCheckConfig(),
    this.controller,
  });

  @override
  State<LivenessCheckScreen> createState() => _LivenessCheckScreenState();
}

class _LivenessCheckScreenState extends State<LivenessCheckScreen> {
  /// Camera controller for managing camera operations
  CameraController? _cameraController;

  /// Face detector instance for ML Kit face detection
  FaceDetector? _faceDetector;

  /// Prevents multiple simultaneous face detection operations
  bool _isDetecting = false;

  /// Tracks camera initialization status
  bool _isCameraInitialized = false;

  /// Tracks if camera is being disposed
  bool _isDisposing = false;

  // Liveness check state
  /// Current number of detected eye blinks
  int _blinkCount = 0;

  /// Whether user is currently smiling with visible teeth
  bool _isSmiling = false;

  /// Prevents multiple photo captures after liveness completion
  bool _livenessCompleted = false;

  // UI state
  /// Border color for the circular camera preview
  late Color _borderColor;

  /// Current error or instruction message displayed to user
  String _errorMessage = '';

  /// Prevents multiple photo capture operations
  bool _isProcessing = false;

  // Tracking variables

  /// Tracks if eye blink detection is in progress
  bool _isBlinkInProgress = false;

  /// Number of consecutive frames with eyes closed
  int _framesWithEyesClosed = 0;

  /// Consecutive frames with poor image quality
  int _poorQualityFrames = 0;

  /// Current camera image for enhanced quality analysis
  CameraImage? _currentCameraImage;

  /// Current retry attempt count
  int _retryAttemptCount = 0;

  @override
  void initState() {
    super.initState();
    _borderColor = widget.config.theme.borderColor;

    // Register controller callbacks
    widget.controller?.registerInitializeCallback(() {
      _initializeCamera();
      _initializeFaceDetector();
    });
    widget.controller?.registerDisposeCallback(_disposeCamera);
    widget.controller?.registerResetCallback(_resetLivenessState);

    _initializeCamera();
    _initializeFaceDetector();
  }

  @override
  void didUpdateWidget(LivenessCheckScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle status changes
    if (oldWidget.config.status != widget.config.status) {
      if (widget.config.status == LivenessStatus.init) {
        // Reset retry counter when status changes back to init
        _retryAttemptCount = 0;

        // Initialize camera when switching to init status
        if (_cameraController == null ||
            !_cameraController!.value.isInitialized) {
          _initializeCamera();
          _initializeFaceDetector();
          // Trigger rebuild to show camera preview
          if (mounted) {
            setState(() {});
          }
        }
      } else {
        // Dispose camera when switching away from init status
        _disposeCamera();
      }
    }

    // Update border color based on new status
    setState(() {
      _borderColor = widget.config.theme.borderColor;
    });
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      // Set disposing flag first to stop any rebuilds
      if (mounted) {
        setState(() {
          _isDisposing = true;
          _isCameraInitialized = false;
        });
      }

      try {
        // Stop image stream if still running
        if (_cameraController!.value.isStreamingImages) {
          await _cameraController!.stopImageStream();
        }
      } catch (e) {
        debugPrint('Error stopping image stream: $e');
      }

      // Small delay to ensure no pending frame processing
      await Future.delayed(const Duration(milliseconds: 100));

      try {
        // Dispose camera controller
        await _cameraController!.dispose();
      } catch (e) {
        debugPrint('Error disposing camera: $e');
      }

      _cameraController = null;

      // Notify controller
      widget.controller?.setInitialized(false);
    }

    // Close MLKit detector
    try {
      _faceDetector?.close();
    } catch (e) {
      debugPrint('Error closing face detector: $e');
    }

    // Reset disposing flag
    if (mounted) {
      setState(() {
        _isDisposing = false;
      });
    }
  }

  void _onTryAgain() {
    // Increment retry counter
    _retryAttemptCount++;

    // Check if max retry attempts reached
    if (_retryAttemptCount >= widget.config.settings.maxRetryAttempts) {
      // Call max retry reached callback
      widget.config.callbacks?.onMaxRetryReached?.call(_retryAttemptCount);
      return;
    }

    // Call the onTryAgain callback
    widget.config.callbacks?.onTryAgain?.call();

    // Reset internal state
    setState(() {
      _isProcessing = false;
      _livenessCompleted = false;
      _errorMessage = '';
      _blinkCount = 0;
      _framesWithEyesClosed = 0;
      _poorQualityFrames = 0;
      _borderColor = widget.config.theme.borderColor;
    });

    // Reinitialize camera and face detector
    // _initializeCamera();
    // _initializeFaceDetector();
  }

  void _handleError(LivenessCheckError errorType, [String? technicalDetails]) {
    final message = errorType.getCustomMessage(widget.config.messages);

    setState(() {
      _errorMessage = message;
      _borderColor = widget.config.theme.errorColor;
    });

    // Call both callback types for backward compatibility
    widget.config.callbacks?.onError?.call(message);
    widget.config.callbacks?.onErrorWithType?.call(errorType, message);
  }

  /// Initializes the camera and requests necessary permissions.
  ///
  /// This method:
  /// - Requests camera permission from the user
  /// - Handles permission denied cases with option to open settings
  /// - Finds and configures the front-facing camera
  /// - Sets up camera controller with NV21 format for better ML Kit compatibility
  /// - Starts the image stream for real-time face detection
  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      // Check if permission is permanently denied
      if (status == PermissionStatus.permanentlyDenied) {
        // Show dialog to navigate to settings
        if (mounted) {
          final permissionConfig =
              widget.config.messages.permissionDialogConfig;
          final shouldOpenSettings = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(permissionConfig.title),
              content: Text(permissionConfig.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(permissionConfig.cancelButtonText),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(permissionConfig.settingsButtonText),
                ),
              ],
            ),
          );

          if (shouldOpenSettings == true) {
            // Open app settings
            await openAppSettings();
          }
        }
      }
      _handleError(LivenessCheckError.cameraPermissionDenied);
      return;
    }

    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        widget.config.cameraSettings?.resolutionPreset ?? ResolutionPreset.high,
        enableAudio: widget.config.cameraSettings?.enableAudio ?? false,
        imageFormatGroup: widget.config.cameraSettings?.imageFormatGroup ??
            (Platform.isAndroid
                ? ImageFormatGroup.nv21
                : ImageFormatGroup.bgra8888),
      );

      await _cameraController!.initialize();

      setState(() {
        _isCameraInitialized = true;
      });

      // Notify controller
      widget.controller?.setInitialized(true);

      _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      _handleError(LivenessCheckError.cameraInitializationFailed, e.toString());
    }
  }

  /// Initializes the ML Kit face detector with optimal settings for liveness detection.
  ///
  /// Enables:
  /// - Contours: For detailed face shape analysis
  /// - Landmarks: For precise eye, nose, and mouth detection
  /// - Classification: For eye open/close and smile probability
  /// - Tracking: For consistent face identification across frames
  /// - Accurate mode: For better quality detection at the cost of performance
  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true,
        enableTracking: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  /// Processes each camera frame for face detection and quality analysis.
  ///
  /// This method is called for every camera frame and:
  /// - Prevents concurrent processing to avoid performance issues
  /// - Stores the current image for quality analysis
  /// - Converts camera image to ML Kit compatible format
  /// - Triggers face detection and analysis
  ///
  /// [image] The camera frame to process
  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting ||
        !_isCameraInitialized ||
        _livenessCompleted ||
        _isDisposing) {
      return;
    }

    _isDetecting = true;
    _currentCameraImage = image; // Store current image
    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage != null) {
        await _detectFaces(inputImage);
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isDetecting = false;
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      // Get image rotation based on device orientation
      final rotation = _getImageRotation();

      // Convert image format with proper handling
      InputImageFormat format;

      if (image.format.group == ImageFormatGroup.yuv420 ||
          image.format.group == ImageFormatGroup.nv21) {
        format = InputImageFormat.nv21;
        return _convertYUV420ToInputImage(image, rotation, format);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        format = InputImageFormat.bgra8888;
        return _convertBGRA8888ToInputImage(image, rotation, format);
      } else {
        // Try to get format from raw value, with fallback
        final formatFromRaw = InputImageFormatValue.fromRawValue(
          image.format.raw,
        );
        if (formatFromRaw != null) {
          format = formatFromRaw;
          return _convertYUV420ToInputImage(image, rotation, format);
        } else {
          // Fallback to NV21 format for most Android devices
          format = InputImageFormat.nv21;
          debugPrint('Unknown format ${image.format.raw}, using NV21 fallback');
          return _convertYUV420ToInputImage(image, rotation, format);
        }
      }
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }

  InputImage _convertYUV420ToInputImage(
    CameraImage image,
    InputImageRotation rotation,
    InputImageFormat format,
  ) {
    // Concatenate all plane bytes for YUV420 format
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  InputImage _convertBGRA8888ToInputImage(
    CameraImage image,
    InputImageRotation rotation,
    InputImageFormat format,
  ) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  InputImageRotation _getImageRotation() {
    final sensorOrientation = _cameraController!.description.sensorOrientation;

    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  /// Detects faces in the input image and performs quality checks.
  ///
  /// This method:
  /// - Uses ML Kit to detect faces in the camera frame
  /// - Validates single face presence (rejects multiple faces)
  /// - Performs enhanced blur and lighting quality analysis
  /// - Routes to appropriate processing based on detection results
  ///
  /// [inputImage] The ML Kit compatible image for face detection
  Future<void> _detectFaces(InputImage inputImage) async {
    try {
      final List<Face> faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) {
        _handleError(LivenessCheckError.noFaceDetected);
        _resetLivenessState();
      } else if (faces.length > 1) {
        _handleError(LivenessCheckError.multipleFacesDetected);
        _resetLivenessState();
      } else {
        // Enhanced blur detection
        final blurResult = EnhancedQualityDetector.detectBlur(
          _currentCameraImage!,
          faces.first,
        );

        // Enhanced lighting detection
        final lightingResult = EnhancedQualityDetector.detectLighting(
          _currentCameraImage!,
          faces.first,
        );

        // Check overall quality
        final hasQualityIssue =
            blurResult.isBlurry || !lightingResult.isGoodLighting;

        if (hasQualityIssue) {
          // Only show error after multiple consecutive poor quality frames (increased threshold)
          _handleQualityIssue(blurResult, lightingResult);
          _resetLivenessState();
          return;
        } else {
          setState(() {
            _poorQualityFrames = 0; // Reset counter on good quality frame
          });
        }

        if (!hasQualityIssue || _poorQualityFrames <= 10) {
          _processSingleFace(faces.first);
        }
      }
    } catch (e) {
      debugPrint('Error detecting faces: $e');
    }
  }

  /// Processes a single detected face for liveness verification.
  ///
  /// This method performs the core liveness detection by:
  /// - Analyzing eye blink patterns with head movement filtering
  /// - Detecting smiles that show visible teeth
  /// - Updating the overall liveness verification status
  ///
  /// Only called when image quality is acceptable and exactly one face is detected.
  ///
  /// [face] The detected face from ML Kit containing landmarks and probabilities
  void _processSingleFace(Face face) {
    // Check eye blink
    _checkEyeBlink(face);

    // Check smile
    _checkSmile(face);

    // Update liveness status
    _updateLivenessStatus();
  }

  /// Handles quality issues detected in the camera image.
  ///
  /// Analyzes blur and lighting detection results to provide specific
  /// user-friendly error messages for different quality problems.
  ///
  /// [blurResult] The blur detection analysis result
  /// [lightingResult] The lighting condition analysis result
  void _handleQualityIssue(
    BlurDetectionResult blurResult,
    LightingDetectionResult lightingResult,
  ) {
    if (blurResult.isBlurry) {
      if (blurResult.faceArea < 8000) {
        _handleError(LivenessCheckError.moveCloserToCamera);
      } else if (!blurResult.landmarkStability) {
        _handleError(LivenessCheckError.faceNotClear);
      } else {
        _handleError(LivenessCheckError.imageBlurry);
      }
    } else if (!lightingResult.isGoodLighting) {
      _handleError(
        LivenessCheckError.poorLighting,
        lightingResult.issueDescription,
      );
    }
  }

  /// Detects eye blinks while filtering out false positives from head movement.
  ///
  /// This method implements sophisticated blink detection that:
  /// - Monitors eye open/close probabilities from ML Kit
  /// - Filters out false positives caused by head shaking or rotation
  /// - Requires eyes to be closed for 2-10 consecutive frames to count as valid blink
  /// - Resets detection state when significant head movement is detected
  ///
  /// [face] The detected face containing eye probability data and head angles
  void _checkEyeBlink(Face face) {
    final leftEyeOpenProb = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpenProb = face.rightEyeOpenProbability ?? 1.0;

    // Check head movement to avoid false blink detection
    final headYaw = face.headEulerAngleY?.abs() ?? 0;
    final headPitch = face.headEulerAngleX?.abs() ?? 0;
    final headRoll = face.headEulerAngleZ?.abs() ?? 0;

    // Don't detect blinks if head is moving significantly
    final isHeadMoving = headYaw > 15 || headPitch > 15 || headRoll > 15;

    if (isHeadMoving) {
      // Reset blink detection if head is moving
      _isBlinkInProgress = false;
      _framesWithEyesClosed = 0;
      return;
    }

    final eyesOpen = leftEyeOpenProb > 0.6 && rightEyeOpenProb > 0.6;
    final eyesClosed = leftEyeOpenProb < 0.3 && rightEyeOpenProb < 0.3;

    if (eyesClosed && !_isBlinkInProgress) {
      // Start of potential blink
      _isBlinkInProgress = true;
      _framesWithEyesClosed = 1;
    } else if (eyesClosed && _isBlinkInProgress) {
      // Continue counting closed frames
      _framesWithEyesClosed++;

      // If eyes stay closed too long, it's not a blink
      if (_framesWithEyesClosed > 10) {
        _isBlinkInProgress = false;
        _framesWithEyesClosed = 0;
      }
    } else if (eyesOpen && _isBlinkInProgress && _framesWithEyesClosed >= 2) {
      // Valid blink completed: eyes were closed for 2-10 frames, now open
      _blinkCount++;
      debugPrint('Blink detected! Count: $_blinkCount');
      _isBlinkInProgress = false;
      _framesWithEyesClosed = 0;
    } else if (eyesOpen) {
      // Eyes are open, reset if not in valid blink
      if (!_isBlinkInProgress) {
        _framesWithEyesClosed = 0;
      }
    }
  }

  /// Detects genuine smiles that show visible teeth.
  ///
  /// This method goes beyond simple smile probability by:
  /// - Analyzing mouth landmarks to detect open mouth
  /// - Calculating mouth height-to-width ratio to verify teeth visibility
  /// - Requiring both high smile probability AND mouth opening
  /// - Preventing false positives from closed-mouth smiles
  ///
  /// [face] The detected face containing smile probability and mouth landmarks
  void _checkSmile(Face face) {
    final smileProb = face.smilingProbability ?? 0.0;

    // Get mouth landmarks to check for open mouth (showing teeth)
    final landmarks = face.landmarks;
    final mouthBottom = landmarks[FaceLandmarkType.bottomMouth];
    final mouthLeft = landmarks[FaceLandmarkType.leftMouth];
    final mouthRight = landmarks[FaceLandmarkType.rightMouth];

    // Check if mouth landmarks are available and mouth appears open
    bool hasOpenMouth = false;
    if (mouthBottom != null && mouthLeft != null && mouthRight != null) {
      // Calculate mouth width and height approximation
      final mouthWidth = (mouthRight.position.x - mouthLeft.position.x).abs();
      final mouthHeight = (mouthBottom.position.y -
              ((mouthLeft.position.y + mouthRight.position.y) / 2))
          .abs();

      // Mouth should be relatively wide and open (showing teeth)
      final mouthRatio = mouthHeight / mouthWidth;
      hasOpenMouth = mouthRatio > 0.15; // Threshold for open mouth
    }

    // Require both high smile probability AND open mouth (visible teeth)
    _isSmiling = smileProb > 0.8 && hasOpenMouth;
  }

  /// Updates the liveness verification status and handles completion.
  ///
  /// This method:
  /// - Checks if liveness requirements are met (3 blinks OR smile with teeth)
  /// - Prevents multiple photo captures with completion flag
  /// - Updates UI with progress indicators
  /// - Triggers photo capture when verification succeeds
  void _updateLivenessStatus() {
    if ((_blinkCount >= 3 || _isSmiling) && !_livenessCompleted) {
      _livenessCompleted = true;
      setState(() {
        _errorMessage = widget.config.messages.livenessCheckPassed;
        _borderColor = Colors.green;
      });
      _capturePhoto();
    } else if (!_livenessCompleted) {
      // final blinkStatus = _blinkCount >= 3 ? '✓' : '$_blinkCount/3';
      // final smileStatus = _isSmiling ? '✓' : '✗';
      setState(() {
        _errorMessage = "";
        // _errorMessage = 'Blink 3 times: $blinkStatus, Smile: $smileStatus';
        _borderColor = widget.config.theme.borderColor;
      });
    }
  }

  /// Builds an enhanced error message widget with technical details.
  ///
  /// Creates a comprehensive error display that includes:
  /// - Main user-friendly error message
  /// - Technical debugging information (blur and lighting analysis)
  /// - Toggle for showing/hiding detailed technical data
  /// - Color-coded styling based on error type
  ///
  /// Returns [Widget.shrink] if no error message is present.
  Widget _buildEnhancedErrorMessage() {
    if (_errorMessage.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Main error message
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: _getMessageTextStyle(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Resets all liveness detection state variables to initial values.
  ///
  /// Called when:
  /// - Face detection fails or quality issues are detected
  /// - User needs to restart the liveness verification process
  /// - Multiple faces are detected
  void _resetLivenessState() {
    setState(() {
      _blinkCount = 0;
      _isSmiling = false;
      _livenessCompleted = false;
      _isBlinkInProgress = false;
      _framesWithEyesClosed = 0;
      _poorQualityFrames = 0;
    });
  }

  /// Captures a photo and navigates to the result screen.
  ///
  /// This method:
  /// - Stops the camera image stream to prevent interference
  /// - Takes a high-quality photo using the camera controller
  /// - Handles widget lifecycle (mounted check) for safe navigation
  /// - Navigates to LivenessResultScreen with the captured image
  /// - Provides error recovery by restarting image stream on failure
  Future<void> _capturePhoto() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Stop the image stream first
      await _cameraController!.stopImageStream();

      final XFile photo = await _cameraController!.takePicture();

      // Check if widget is still mounted before navigation
      if (!mounted) return;

      // Call photo taken callback
      widget.config.callbacks?.onPhotoTaken?.call(photo.path);

      // Navigate to result screen only if auto-navigation is enabled
      if (widget.config.settings.autoNavigateOnSuccess) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => LivenessResultScreen(imagePath: photo.path),
        //   ),
        // );
      }
      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _livenessCompleted = false;
        });
        _handleError(LivenessCheckError.photoCaptureFailed, e.toString());
        // Restart image stream if capture failed
        if (_cameraController != null &&
            _cameraController!.value.isInitialized) {
          _cameraController!.startImageStream(_processCameraImage);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which view to show based on status
    Widget bodyContent;

    if (widget.config.status == LivenessStatus.init) {
      // For init status, check if camera is ready
      final isCameraReady = !_isDisposing &&
          _isCameraInitialized &&
          _cameraController != null &&
          _cameraController!.value.isInitialized;

      bodyContent = isCameraReady ? _buildCameraView() : _buildLoadingView();
    } else {
      // For success/fail status, always show the camera view (it shows icons)
      bodyContent = _buildCameraView();
    }

    return Scaffold(
      backgroundColor: widget.config.theme.backgroundColor,
      appBar: _buildCustomAppBar(),
      body: Column(
        children: [
          Expanded(child: bodyContent),
          if (widget.config.customBottomWidget != null &&
              !widget.config.settings.showTryAgainButton)
            widget.config.customBottomWidget!,
        ],
      ),
    );
  }

  AppBar _buildCustomAppBar() {
    final appBarConfig = widget.config.appBarConfig;

    return AppBar(
      title: Text(
        appBarConfig.title ?? widget.config.messages.title,
        style: appBarConfig.titleStyle ??
            widget.config.theme.titleTextStyle ??
            TextStyle(
              color: widget.config.theme.textColor,
              fontFamily: widget.config.theme.fontFamily,
            ),
      ),
      backgroundColor:
          appBarConfig.backgroundColor ?? widget.config.theme.backgroundColor,
      elevation: appBarConfig.elevation ?? 0,
      foregroundColor: widget.config.theme.textColor,
      centerTitle: appBarConfig.centerTitle,
      automaticallyImplyLeading:
          appBarConfig.automaticallyImplyLeading && appBarConfig.showBackButton,
      leading: (appBarConfig.automaticallyImplyLeading &&
              appBarConfig.showBackButton)
          ? (appBarConfig.customBackIcon ??
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: widget.config.theme.textColor,
                ),
                onPressed: () {
                  widget.config.callbacks?.onCancel?.call();
                  Navigator.of(context).pop();
                },
              ))
          : null,
    );
  }

  Widget _buildLoadingView() {
    // Use custom loading widget if provided
    if (widget.config.customCameraLoadingWidget != null) {
      return widget.config.customCameraLoadingWidget!;
    }

    // Default loading view
    return SizedBox();
  }

  TextStyle _getMessageTextStyle() {
    if (_borderColor == widget.config.theme.successColor) {
      return widget.config.theme.successTextStyle ??
          TextStyle(
            fontSize: 16,
            color: widget.config.theme.successColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
            fontFamily: widget.config.theme.fontFamily,
          );
    } else if (_borderColor == widget.config.theme.errorColor) {
      return widget.config.theme.errorTextStyle ??
          TextStyle(
            fontSize: 16,
            color: widget.config.theme.errorColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
            fontFamily: widget.config.theme.fontFamily,
          );
    } else {
      return widget.config.theme.messageTextStyle ??
          TextStyle(
            fontSize: 16,
            color: widget.config.theme.primaryColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
            fontFamily: widget.config.theme.fontFamily,
          );
    }
  }

  Widget _buildCircleWithContent(double circleSize, Size screenSize) {
    final cameraPadding = widget.config.theme.cameraPadding;
    final innerContentSize = circleSize - (cameraPadding * 2);

    // Determine inner content based on status
    Widget innerContent;

    switch (widget.config.status) {
      case LivenessStatus.success:
        innerContent = Image.asset(
          widget.config.theme.successAsset ??
              'packages/flutter_liveness_check/assets/success.png',
          width: innerContentSize,
          height: innerContentSize,
          fit: BoxFit.contain,
        );
        break;

      case LivenessStatus.fail:
        innerContent = Image.asset(
          widget.config.theme.failAsset ??
              'packages/flutter_liveness_check/assets/fail.png',
          width: innerContentSize,
          height: innerContentSize,
          fit: BoxFit.contain,
        );
        break;

      case LivenessStatus.init:
        // For init status, show camera preview
        if (!_isDisposing &&
            _cameraController != null &&
            _cameraController!.value.isInitialized &&
            !_cameraController!.value.isPreviewPaused) {
          innerContent = OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: SizedBox(
                width: screenSize.width,
                height: screenSize.width * _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            ),
          );
        } else {
          innerContent = Container(
            width: innerContentSize,
            height: innerContentSize,
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.config.theme.primaryColor,
                ),
              ),
            ),
          );
        }
        break;
    }

    Widget circleWidget;

    if (widget.config.theme.borderStyle == CircleBorderStyle.dashed) {
      // Use CustomPaint for dashed border
      circleWidget = CustomPaint(
        size: Size(circleSize, circleSize),
        painter: DashedCirclePainter(
          color: _borderColor,
          strokeWidth: widget.config.theme.borderWidth,
          dashLength: widget.config.theme.dashLength,
          dashGap: widget.config.theme.dashGap,
        ),
        child: SizedBox(
          width: circleSize,
          height: circleSize,
          child: Center(
            child: ClipOval(
              child: SizedBox(
                width: innerContentSize,
                height: innerContentSize,
                child: innerContent,
              ),
            ),
          ),
        ),
      );
    } else {
      // Use solid border
      circleWidget = Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _borderColor,
            width: widget.config.theme.borderWidth,
          ),
        ),
        child: Center(
          child: ClipOval(
            child: SizedBox(
              width: innerContentSize,
              height: innerContentSize,
              child: innerContent,
            ),
          ),
        ),
      );
    }

    return circleWidget;
  }

  Widget _buildCameraView() {
    final size = MediaQuery.of(context).size;
    final circleSize = size.width * widget.config.theme.circleSize;
    final centerY = size.height * widget.config.settings.circlePositionY;

    return Stack(
      children: [
        // Camera preview (only for init status)
        if (!_isDisposing &&
            widget.config.status == LivenessStatus.init &&
            _cameraController != null &&
            _cameraController!.value.isInitialized &&
            !_cameraController!.value.isPreviewPaused)
          Positioned.fill(child: CameraPreview(_cameraController!)),

        // White overlay with circular cutout
        Positioned.fill(
          child: Container(
            color: widget.config.theme.overlayColor,
            child: Stack(
              children: [
                // Circle positioned at specific location
                Positioned(
                  left: (size.width - circleSize) / 2,
                  top: centerY - (circleSize / 2),
                  child: _buildCircleWithContent(circleSize, size),
                ),
              ],
            ),
          ),
        ),

        // Instructions and error messages
        Positioned(
          bottom: size.height * widget.config.settings.circlePositionY - 80,
          left: 20,
          right: 20,
          child: Column(
            children: [
              if (_errorMessage.isNotEmpty &&
                  widget.config.settings.showErrorMessage) ...[
                _buildEnhancedErrorMessage(),
              ] else if (widget.config.placeholder != null) ...[
                Text(
                  widget.config.placeholder ?? '',
                  textAlign: TextAlign.center,
                  style: widget.config.theme.messageTextStyle ??
                      TextStyle(
                        fontSize: 16,
                        color: widget.config.theme.primaryColor,
                        fontFamily: widget.config.theme.fontFamily,
                      ),
                ),
              ],
            ],
          ),
        ),

        // Processing indicator
        if (widget.config.showLoading)
          Positioned.fill(
            child: widget.config.customLoadingWidget ??
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.config.theme.primaryColor,
                      ),
                    ),
                  ),
                ),
          ),

        // Try Again button for fail status (only if no custom bottom widget)
        if (widget.config.status == LivenessStatus.fail &&
            widget.config.settings.showTryAgainButton &&
            widget.config.customBottomWidget == null)
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: SizedBox(
              height: widget.config.theme.btnRetryHeight,
              child: ElevatedButton(
                onPressed: _onTryAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.config.theme.btnRetryBGColor,
                  foregroundColor: widget.config.theme.btnTextRetryColor,
                  padding: widget.config.theme.btnRetryPadding ??
                      const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                  minimumSize: widget.config.theme.btnRetryHeight != null
                      ? Size.fromHeight(widget.config.theme.btnRetryHeight!)
                      : const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      widget.config.theme.btnRetryBorderRadius ?? 8,
                    ),
                  ),
                ),
                child: Text(
                  widget.config.messages.tryAgainButtonText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: widget.config.theme.fontFamily,
                    color: widget.config.theme.btnTextRetryColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    // Stop image stream if still running
    if (_cameraController?.value.isStreamingImages ?? false) {
      _cameraController?.stopImageStream();
    }

    // Dispose camera controller
    _cameraController?.dispose();
    _cameraController = null;

    // Close MLKit detector
    _faceDetector?.close();
    super.dispose();
  }
}
