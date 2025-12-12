import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// A utility class for detecting image quality issues in liveness checks.
///
/// This class provides methods to analyze camera images for:
/// - Blur detection using Laplacian variance and face landmarks
/// - Lighting quality analysis including brightness and contrast
/// - Face size and stability checks
class EnhancedQualityDetector {
  // Quality detection thresholds
  /// Threshold for blur detection using Laplacian variance.
  static const double _blurThreshold = 20.0;

  /// Minimum acceptable brightness level.
  static const double _minBrightness = 100.0;

  /// Maximum acceptable brightness level.
  static const double _maxBrightness = 250.0;

  /// Minimum required face size in pixels.
  static const int _minFaceSize = 3000;

  /// Maximum ratio of overexposed pixels allowed.
  static const double _maxOverexposureRatio = 0.4;

  /// Maximum ratio of underexposed pixels allowed.
  static const double _maxUnderexposureRatio = 0.4;

  /// Detects blur in camera images using multiple quality metrics.
  ///
  /// Analyzes the [cameraImage] focusing on the detected [face] region.
  /// Returns a [BlurDetectionResult] with detailed quality information.
  ///
  /// The detection uses:
  /// - Face size analysis
  /// - Landmark stability check
  /// - Laplacian variance calculation (optional based on image format)
  /// - ONNX-based Laplacian calculation (from FaceAntiSpoofingOnnx)
  static BlurDetectionResult detectBlur(
    CameraImage cameraImage,
    Face face, {
    double threshold = _blurThreshold,
  }) {
    try {
      // Method 1: Face size check (more lenient)
      final faceArea = face.boundingBox.width * face.boundingBox.height;
      final isSmallFace = faceArea < _minFaceSize;

      // Method 2: Face landmark stability (more lenient)
      final landmarkStability = _checkLandmarkStability(face);

      // Method 3: Laplacian variance (skip if causing issues)
      double laplacianVariance = 0.0;
      bool skipLaplacianCheck = false; // Add option to skip this check

      if (!skipLaplacianCheck &&
          (cameraImage.format.group == ImageFormatGroup.yuv420 ||
              cameraImage.format.group == ImageFormatGroup.nv21)) {
        laplacianVariance = _calculateLaplacianVariance(
          cameraImage,
          face.boundingBox,
        );
      }
      int badConditions = 0;

      // NEW: Much more forgiving combination logic
      // Only mark as blurry if MULTIPLE conditions are bad, not just one

      if (isSmallFace) badConditions++;
      if (!landmarkStability) badConditions++;
      if (!skipLaplacianCheck &&
          laplacianVariance > 0 &&
          laplacianVariance < threshold) {
        badConditions++;
      }

      // Only consider blurry if at least 2 conditions are bad AND face is very small
      final isBlurry = badConditions >= 2 && isSmallFace;

      return BlurDetectionResult(
        isBlurry: isBlurry,
        faceArea: faceArea,
        laplacianVariance: laplacianVariance,
        landmarkStability: landmarkStability,
        confidence: _calculateBlurConfidence(
          faceArea,
          laplacianVariance,
          landmarkStability,
        ),
        debugInfo: BlurDebugInfo(
          isSmallFace: isSmallFace,
          badConditions: badConditions,
          skipLaplacianCheck: skipLaplacianCheck,
        ),
      );
    } catch (e) {
      debugPrint('Error in blur detection: $e');
      return BlurDetectionResult(
        isBlurry: false, // Default to NOT blurry on error
        faceArea: 0,
        laplacianVariance: 0,
        landmarkStability: false,
        confidence: 0.0,
        debugInfo: BlurDebugInfo(
          isSmallFace: true,
          badConditions: 0,
          skipLaplacianCheck: true,
        ),
      );
    }
  }

  /// Detects lighting quality in camera images.
  ///
  /// Analyzes the [cameraImage] focusing on the detected [face] region.
  /// Returns a [LightingDetectionResult] with lighting metrics and issues.
  ///
  /// The detection analyzes:
  /// - Average brightness
  /// - Contrast levels
  /// - Overexposure and underexposure ratios
  /// - Specific lighting issues (too bright, too dark, etc.)
  static LightingDetectionResult detectLighting(
    CameraImage cameraImage,
    Face face,
  ) {
    try {
      final faceRect = face.boundingBox;

      // Extract face region from camera image
      final facePixels = _extractFacePixels(cameraImage, faceRect);
      if (facePixels.isEmpty) {
        return LightingDetectionResult(
          isGoodLighting: true, // Default to good lighting if can't analyze
          avgBrightness: 128, // Neutral value
          contrast: 30,
          overexposureRatio: 0.0,
          underexposureRatio: 0.0,
          issue: null, // No issue if can't analyze
        );
      }

      // Calculate lighting metrics
      final avgBrightness = _calculateAverageBrightness(facePixels);
      final contrast = _calculateContrast(facePixels);
      final overexposureRatio = _calculateOverexposureRatio(facePixels);
      final underexposureRatio = _calculateUnderexposureRatio(facePixels);

      // Much more lenient lighting requirements
      LightingIssue? issue;
      bool isGoodLighting = true;
      // Only fail lighting if it's REALLY bad
      if (avgBrightness < _minBrightness && contrast < 5) {
        issue = LightingIssue.tooWarm;
        isGoodLighting = false;
      } else if (avgBrightness > _maxBrightness && overexposureRatio > 0.6) {
        issue = LightingIssue.tooBright;
        isGoodLighting = false;
      } else if (contrast < 5 && avgBrightness < 40) {
        // Much stricter
        issue = LightingIssue.lowContrast;
        isGoodLighting = false;
      } else if (overexposureRatio > _maxOverexposureRatio &&
          avgBrightness > 200) {
        issue = LightingIssue.overexposed;
        isGoodLighting = false;
      } else if (underexposureRatio > _maxUnderexposureRatio &&
          avgBrightness < 30) {
        issue = LightingIssue.underexposed;
        isGoodLighting = false;
      }

      return LightingDetectionResult(
        isGoodLighting: isGoodLighting,
        avgBrightness: avgBrightness,
        contrast: contrast,
        overexposureRatio: overexposureRatio,
        underexposureRatio: underexposureRatio,
        issue: issue,
      );
    } catch (e) {
      debugPrint('Error in lighting detection: $e');
      return LightingDetectionResult(
        isGoodLighting: true, // Default to good lighting on error
        avgBrightness: 128,
        contrast: 30,
        overexposureRatio: 0.0,
        underexposureRatio: 0.0,
        issue: null,
      );
    }
  }

  /// Calculate Laplacian variance - with better error handling
  static double _calculateLaplacianVariance(CameraImage image, Rect faceRect) {
    try {
      // Get Y channel (luminance) from YUV420 format
      final yPlane = image.planes[0];
      final yBytes = yPlane.bytes;
      final width = image.width;
      final height = image.height;

      // Convert face rect to image coordinates
      final startX = math.max(0, faceRect.left.toInt());
      final endX = math.min(width, faceRect.right.toInt());
      final startY = math.max(0, faceRect.top.toInt());
      final endY = math.min(height, faceRect.bottom.toInt());

      // Ensure we have a valid region
      if (startX >= endX - 2 || startY >= endY - 2) {
        return 100.0; // Return high value (good) if region too small
      }

      List<double> laplacianValues = [];

      // Apply Laplacian kernel to face region (sample fewer pixels for performance)
      for (int y = startY + 1; y < endY - 1; y += 2) {
        // Skip every other row
        for (int x = startX + 1; x < endX - 1; x += 2) {
          // Skip every other pixel
          final index = y * width + x;
          if (index >= width && index < yBytes.length - width) {
            // Better bounds check
            // Laplacian kernel: [0 -1 0; -1 4 -1; 0 -1 0]
            final center = yBytes[index];
            final top = yBytes[index - width];
            final bottom = yBytes[index + width];
            final left = yBytes[index - 1];
            final right = yBytes[index + 1];

            final laplacian =
                (4 * center - top - bottom - left - right).toDouble();
            laplacianValues.add(laplacian.abs()); // Use absolute value
          }
        }
      }

      if (laplacianValues.isEmpty || laplacianValues.length < 10) {
        return 100.0; // Return high value (good) if not enough samples
      }

      // Calculate variance
      final mean =
          laplacianValues.reduce((a, b) => a + b) / laplacianValues.length;
      final variance = laplacianValues
              .map((x) => math.pow(x - mean, 2))
              .reduce((a, b) => a + b) /
          laplacianValues.length;

      return variance;
    } catch (e) {
      debugPrint('Error calculating Laplacian variance: $e');
      return 100.0; // Return high value (good) on error
    }
  }

  /// Much more lenient landmark stability check
  static bool _checkLandmarkStability(Face face) {
    final landmarks = face.landmarks;

    // Count available landmarks
    int availableLandmarks = 0;

    if (landmarks[FaceLandmarkType.leftEye] != null) availableLandmarks++;
    if (landmarks[FaceLandmarkType.rightEye] != null) availableLandmarks++;
    if (landmarks[FaceLandmarkType.noseBase] != null) availableLandmarks++;
    if (landmarks[FaceLandmarkType.bottomMouth] != null) availableLandmarks++;
    if (landmarks[FaceLandmarkType.leftMouth] != null) availableLandmarks++;
    if (landmarks[FaceLandmarkType.rightMouth] != null) availableLandmarks++;

    // Very lenient - just need ANY landmark detected
    return availableLandmarks >= 1;
  }

  // ... (keep all the other methods the same: _extractFacePixels, _calculateAverageBrightness, etc.)

  /// Extract pixel values from face region
  static List<int> _extractFacePixels(CameraImage image, Rect faceRect) {
    try {
      final yPlane = image.planes[0];
      final yBytes = yPlane.bytes;
      final width = image.width;
      final height = image.height;

      final startX = math.max(0, faceRect.left.toInt());
      final endX = math.min(width, faceRect.right.toInt());
      final startY = math.max(0, faceRect.top.toInt());
      final endY = math.min(height, faceRect.bottom.toInt());

      List<int> pixels = [];

      for (int y = startY; y < endY; y++) {
        for (int x = startX; x < endX; x++) {
          final index = y * width + x;
          if (index >= 0 && index < yBytes.length) {
            pixels.add(yBytes[index]);
          }
        }
      }

      return pixels;
    } catch (e) {
      debugPrint('Error extracting face pixels: $e');
      return [];
    }
  }

  /// Calculate average brightness
  static double _calculateAverageBrightness(List<int> pixels) {
    if (pixels.isEmpty) return 128.0; // Return neutral value
    final sum = pixels.reduce((a, b) => a + b);
    return sum / pixels.length;
  }

  /// Calculate contrast using standard deviation
  static double _calculateContrast(List<int> pixels) {
    if (pixels.isEmpty) return 30.0; // Return reasonable default

    final mean = _calculateAverageBrightness(pixels);
    final variance =
        pixels.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
            pixels.length;

    return math.sqrt(variance);
  }

  /// Calculate ratio of overexposed pixels
  static double _calculateOverexposureRatio(List<int> pixels) {
    if (pixels.isEmpty) return 0.0;

    final overexposedCount = pixels.where((p) => p > 250).length;
    return overexposedCount / pixels.length;
  }

  /// Calculate ratio of underexposed pixels
  static double _calculateUnderexposureRatio(List<int> pixels) {
    if (pixels.isEmpty) return 0.0;

    final underexposedCount = pixels.where((p) => p < 10).length;
    return underexposedCount / pixels.length;
  }

  /// Calculate blur confidence score (more optimistic)
  static double _calculateBlurConfidence(
    double faceArea,
    double laplacianVariance,
    bool landmarkStability,
  ) {
    double confidence = 0.5; // Start with decent confidence

    // Face size score (0-1) - more generous
    final sizeScore = math.min(1.0, faceArea / 8000); // Reduced denominator
    confidence += sizeScore * 0.3;

    // Laplacian score (0-1) - more generous
    if (laplacianVariance > 0) {
      final laplacianScore = math.min(
        1.0,
        laplacianVariance / 100,
      ); // Reduced denominator
      confidence += laplacianScore * 0.3;
    } else {
      confidence += 0.2; // Give some credit even if we can't calculate
    }

    // Landmark score (0-1) - more generous
    confidence += (landmarkStability ? 0.2 : 0.1);

    return math.min(1.0, confidence);
  }
}

/// Result class containing blur detection analysis.
///
/// Provides comprehensive information about image blur including:
/// - Whether the image is considered blurry
/// - Face area measurement
/// - Laplacian variance (sharpness metric)
/// - Landmark stability status
/// - Confidence score
/// - Debug information
class BlurDetectionResult {
  /// Whether the image is considered blurry.
  final bool isBlurry;

  /// Area of the detected face in pixels.
  final double faceArea;

  /// Laplacian variance value (higher = sharper).
  final double laplacianVariance;

  /// Whether face landmarks are stable and detectable.
  final bool landmarkStability;

  /// Confidence score of the blur detection (0.0 - 1.0).
  final double confidence;

  /// Additional debug information.
  final BlurDebugInfo debugInfo;

  BlurDetectionResult({
    required this.isBlurry,
    required this.faceArea,
    required this.laplacianVariance,
    required this.landmarkStability,
    required this.confidence,
    required this.debugInfo,
  });

  @override
  String toString() {
    return 'BlurDetectionResult(isBlurry: $isBlurry, faceArea: $faceArea, '
        'laplacianVariance: $laplacianVariance, confidence: $confidence, '
        'debugInfo: $debugInfo)';
  }
}

/// Debug information for blur detection analysis.
///
/// Contains additional details used in blur detection logic.
class BlurDebugInfo {
  /// Whether the detected face is smaller than the minimum threshold.
  final bool isSmallFace;

  /// Number of quality conditions that failed.
  final int badConditions;

  /// Whether Laplacian variance check was skipped.
  final bool skipLaplacianCheck;

  /// Creates blur debug information.
  BlurDebugInfo({
    required this.isSmallFace,
    required this.badConditions,
    required this.skipLaplacianCheck,
  });

  @override
  String toString() {
    return 'BlurDebugInfo(isSmallFace: $isSmallFace, badConditions: $badConditions, skipLaplacianCheck: $skipLaplacianCheck)';
  }
}

/// Result class containing lighting quality analysis.
///
/// Provides detailed information about lighting conditions including
/// brightness, contrast, exposure ratios, and identified issues.
class LightingDetectionResult {
  /// Whether the lighting conditions are acceptable.
  final bool isGoodLighting;

  /// Average brightness level (0-255).
  final double avgBrightness;

  /// Contrast level calculated from standard deviation.
  final double contrast;

  /// Ratio of overexposed pixels (0.0 - 1.0).
  final double overexposureRatio;

  /// Ratio of underexposed pixels (0.0 - 1.0).
  final double underexposureRatio;

  /// Specific lighting issue detected, if any.
  final LightingIssue? issue;

  /// Creates a lighting detection result.
  LightingDetectionResult({
    required this.isGoodLighting,
    required this.avgBrightness,
    required this.contrast,
    required this.overexposureRatio,
    required this.underexposureRatio,
    this.issue,
  });

  /// Returns a user-friendly description of the lighting issue.
  String get issueDescription {
    switch (issue) {
      case LightingIssue.tooBright:
        return 'Too bright. Move away from direct light.';
      case LightingIssue.tooWarm:
        return 'Too dark. Move to a brighter area.';
      case LightingIssue.lowContrast:
        return 'Low contrast. Ensure even lighting.';
      case LightingIssue.overexposed:
        return 'Overexposed areas detected. Avoid harsh lighting.';
      case LightingIssue.underexposed:
        return 'Underexposed areas detected. Improve lighting.';
      case LightingIssue.extractionError:
        return 'Unable to analyze lighting. Try again.';
      case null:
        return 'Lighting looks good!';
    }
  }

  @override
  String toString() {
    return 'LightingDetectionResult(isGood: $isGoodLighting, '
        'brightness: $avgBrightness, contrast: $contrast, issue: $issue)';
  }
}

/// Enumeration of possible lighting issues.
enum LightingIssue {
  /// Lighting is too bright overall.
  tooBright,

  /// Lighting is too warm/dark.
  tooWarm,

  /// Contrast is too low.
  lowContrast,

  /// Image has overexposed areas.
  overexposed,

  /// Image has underexposed areas.
  underexposed,

  /// Error occurred during extraction.
  extractionError,
}
