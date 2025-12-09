# Changelog

All notable changes to this project will be documented in this file.

## [1.0.8] - 2025-12-09

### Fixed
- **Camera Initialization Bug**: Fixed camera turning on when `LivenessStatus.fail` is set on screen initialization
  - Camera and face detector now only initialize when status is `LivenessStatus.init`
  - Prevents unnecessary camera access and processing when showing failure state
  - Ensures failure screen displays correctly without camera validation running in background

---

## [1.0.8] - 2025-10-28

### Fixed
- **Android Face Detection**: Relaxed face completeness validation for better detection consistency
  - Reduced mouth width threshold from 0.15 to 0.12 of bounding box width
  - Reduced nose-to-mouth distance threshold from 0.15 to 0.12 of bounding box height
  - Made upper lip contour optional (warning only, not critical)
  - Made mouth left/right landmarks optional, only requiring bottom mouth landmark as critical
  - Aligned Android validation closer to iOS for more consistent cross-platform behavior
- **iOS Face Detection**: Enhanced face detection with improved validation logic
  - Added comprehensive mouth landmark detection
  - Improved contour point validation for better accuracy
  - Enhanced face completeness checks for iOS platform

### Added
- **Custom Button Text Style**: Added `btnRetryTextStyle` parameter to `LivenessCheckTheme`
  - Customize text style for retry button independently
  - Provides more granular control over button appearance

### Changed
- Improved face detection validation to be more consistent across Android and iOS platforms
- Enhanced debug logging for face validation issues

---

## [1.0.7] - 2025-01-28

### Added
- **Flexible Detection Modes**: Added `enableBlinkDetection` and `enableSmileDetection` parameters to `LivenessCheckSettings`
  - Enable or disable blink detection independently
  - Enable or disable smile detection independently
  - Both enabled by default for backward compatibility
  - Uses OR logic: passing either enabled check completes verification
- **Photo Capture Delay**: Added `photoCaptureDelay` parameter to `LivenessCheckSettings`
  - Configure delay before capturing photo after liveness verification passes
  - Default: `Duration(milliseconds: 0)` for immediate capture
  - Useful for giving users time to prepare for the photo
- **Pause/Resume Camera Control**: Added pause and resume methods to `LivenessCheckController`
  - `pauseDetection()`: Pause camera preview and face detection
  - `resumeDetection()`: Resume camera preview and face detection
  - `isPaused` getter: Check current pause status
  - Uses native camera controller methods for efficient resource management
  - Useful for showing dialogs, instructions, or handling app lifecycle events

### Changed
- Updated `LivenessCheckSettings` to include new detection control parameters
- Enhanced `LivenessCheckController` with pause/resume capabilities and status tracking
- Improved camera resource management with pause/resume instead of dispose/reinitialize

### Removed
- **BREAKING**: Removed unused `requireSmile` parameter from `LivenessCheckSettings`
  - Replace with `enableSmileDetection: true/false`

### Migration Guide

#### Update Settings Configuration

**Before:**
```dart
LivenessCheckSettings(
  requiredBlinkCount: 3,
  requireSmile: false,  // Removed parameter
)
```

**After:**
```dart
LivenessCheckSettings(
  enableBlinkDetection: true,   // New: enable/disable blink detection
  requiredBlinkCount: 3,
  enableSmileDetection: false,  // New: enable/disable smile detection
  photoCaptureDelay: Duration(milliseconds: 0),  // New: configurable delay
)
```

#### Use Pause/Resume for Better Performance

**Before:**
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    controller.disposeCamera();  // Heavy operation
  } else if (state == AppLifecycleState.resumed) {
    controller.initializeCamera();  // Heavy operation
  }
}
```

**After:**
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    controller.pauseDetection();  // Lightweight, camera stays initialized
  } else if (state == AppLifecycleState.resumed) {
    controller.resumeDetection();  // Quick resume
  }
}
```

### Examples

#### Blink-Only Detection
```dart
LivenessCheckSettings(
  enableBlinkDetection: true,
  requiredBlinkCount: 3,
  enableSmileDetection: false,  // Disable smile requirement
)
```

#### Smile-Only Detection
```dart
LivenessCheckSettings(
  enableBlinkDetection: false,  // Disable blink requirement
  enableSmileDetection: true,
  photoCaptureDelay: Duration(milliseconds: 500),  // Wait before capture
)
```

#### Pause Detection While Showing Dialog
```dart
Future<void> showInstructions() async {
  await controller.pauseDetection();
  await showDialog(...);
  await controller.resumeDetection();
}
```

---

## [1.0.6] - 2025-10-21
add controller to init and dispose camera and face detect, add button retry custom style
## [1.0.5] - 2025-10-02
fix show camera on IOS , add guide to config permission handler in ReadMe

## [1.0.4] - 2025-10-02
downgrade library version for flutter 3.29.0

## [1.0.3] - 2025-10-01
update sdk suport '>=3.5.0 <4.0.0'

## [1.0.2] - 2025-10-01
add param Camera setting for CameraController
```dart
enum ResolutionPreset {
  low,       // 352x288 (CIF)
  medium,    // 720x480 (NTSC)
  high,      // 1280x720 (HD)
  veryHigh,  // 1920x1080 (Full HD)
  ultraHigh, // 3840x2160 (4K)
  max        // Highest available, varies by device
}
enum ImageFormatGroup {
  unknown,
  jpeg,     // Compressed, smaller, good for storage/sharing
  yuv420,   // Raw format, great for real-time processing (default)
  bgra8888, // iOS-friendly, raw format
}

CameraSettings(
    //ResolutionPreset
    this.resolutionPreset = ResolutionPreset.high,
    //controls microphone input
    this.enableAudio = false,
    //ImageFormatGroup
    this.imageFormatGroup,
)
```
---

## [1.0.1] - 2025-09-20
Update Readme

---
## [1.0.0] - 2025-09-20

### Added
- Comprehensive configuration system with `LivenessCheckConfig`
- Type-safe error handling with `LivenessCheckError` enum
- Complete AppBar customization through `AppBarConfig`
- Advanced theming support with `LivenessCheckTheme`
- Customizable callback system with `LivenessCheckCallbacks`
- Localization support through `LivenessCheckMessages`
- Behavioral configuration via `LivenessCheckSettings`
- Back button visibility control with `showBackButton` parameter
- Custom loading widget support
- Custom bottom widget support
- Dashed and solid circle border styles
- Enhanced blur and lighting quality detection
- Retry logic with configurable maximum attempts
- Font family customization for all text elements
- Success and fail asset replacement
- Progress tracking with callback support
- Enhanced error messages with technical details
- Comprehensive test coverage for all components

### Changed
- **BREAKING**: Replaced `customHeader` parameter with `AppBarConfig` for better control
- **BREAKING**: Moved all styling options to `LivenessCheckTheme`
- **BREAKING**: Centralized all text messages in `LivenessCheckMessages`
- **BREAKING**: Moved behavioral settings to `LivenessCheckSettings`
- Improved face detection accuracy with ML Kit integration
- Enhanced camera initialization and error handling
- Better memory management and resource disposal
- Optimized image processing for better performance
- Updated examples to demonstrate new configuration system

### Fixed
- Camera permission handling on both iOS and Android
- Image format compatibility across different devices
- Memory leaks in camera and ML Kit operations
- Face detection stability during head movement
- Blink detection accuracy with false positive filtering
- Quality detection thresholds for better user experience
- AppBar back button behavior and customization
- Widget lifecycle management and disposal
- Test compatibility issues after API changes

### Removed
- `customHeader` parameter (replaced with `AppBarConfig`)
- Hardcoded styling options (moved to theme configuration)
- Hardcoded text messages (moved to messages configuration)
- Legacy error handling approach (replaced with enum-based system)

### Developer Experience
- Added comprehensive documentation with usage examples
- Created example applications demonstrating various configurations
- Added troubleshooting guide and performance tips
- Improved error messages for better debugging
- Added development setup instructions
- Created migration guide for breaking changes

### Platform Support
- iOS 10.0+ with Metal support
- Android API level 21+ (Android 5.0)
- Flutter 3.0.0 or higher
- Dart 2.17 or higher
- Support for arm64-v8a, armeabi-v7a, x86_64 on Android
- Support for arm64, x86_64 on iOS

## [Unreleased]

### Planned
- Additional gesture detection options
- Advanced anti-spoofing features
- Integration with popular identity verification services
- Enhanced accessibility features

---

## Migration Guide

### From pre-1.0 to 1.0+

#### Replace customHeader with AppBarConfig

**Before:**
```dart
LivenessCheckConfig(
  customHeader: AppBar(
    title: Text('Custom Title'),
    backgroundColor: Colors.blue,
  ),
)
```

**After:**
```dart
LivenessCheckConfig(
  appBarConfig: AppBarConfig(
    title: 'Custom Title',
    backgroundColor: Colors.blue,
    showBackButton: true,
  ),
)
```

#### Update Error Handling

**Before:**
```dart
LivenessCheckCallbacks(
  onError: (String error) {
    print('Error: $error');
  },
)
```

**After:**
```dart
LivenessCheckCallbacks(
  onError: (String error) {
    print('Error: $error');
  },
  onErrorWithType: (LivenessCheckError errorType, String message) {
    switch (errorType) {
      case LivenessCheckError.cameraPermissionDenied:
        // Handle permission error
        break;
      case LivenessCheckError.noFaceDetected:
        // Handle no face error
        break;
      // ... handle other error types
    }
  },
)
```

#### Update Theme Configuration

**Before:**
```dart
// Styling was mixed with main config
LivenessCheckScreen(
  config: LivenessCheckConfig(
    // Various styling options scattered
  ),
)
```

**After:**
```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    theme: LivenessCheckTheme(
      backgroundColor: Colors.white,
      primaryColor: Colors.blue,
      borderStyle: CircleBorderStyle.solid,
      // All styling centralized
    ),
    // Other configurations separated
  ),
)
```

## Support

- **Documentation**: [README.md](README.md)
- **Examples**: Check the `example/` directory
- **Issues**: [GitHub Issues](https://github.com/your-org/flutter_liveness_check/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/flutter_liveness_check/discussions)