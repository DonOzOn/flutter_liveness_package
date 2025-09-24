# Changelog

All notable changes to this project will be documented in this file.

## [0.0.1] - 2024-01-20

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

---

## Support

- **Documentation**: [README.md](README.md)
- **Examples**: Check the `example/` directory
- **Issues**: [GitHub Issues](https://github.com/your-org/flutter_liveness_check/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/flutter_liveness_check/discussions)