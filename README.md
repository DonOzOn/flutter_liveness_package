# 🎭 Flutter Liveness Check Package

A comprehensive Flutter package for face liveness detection with fully customizable UI, AppBar configuration, error handling, and advanced features. Built with ML Kit for accurate face detection, this package provides a complete solution for secure identity verification in mobile applications.

[![pub package](https://img.shields.io/pub/v/flutter_liveness_check.svg)](https://pub.dev/packages/flutter_liveness_check)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://flutter.dev/)

## ✨ Features

- **📷 Real-time Face Detection** - ML Kit powered liveness verification
- **🎨 Fully Customizable UI** - Comprehensive theming and styling options
- **🔧 Flexible AppBar** - Custom titles, back buttons, and complete AppBar control
- **📊 Status Management** - Init, success, and fail states with asset replacement
- **🔄 Retry Logic** - Configurable maximum attempts with callbacks
- **🌍 Localization Support** - Customizable messages and button text
- **🎯 Error Handling** - Type-safe error enums with detailed error information including eyes closed detection
- **🎭 Custom Widgets** - Custom bottom widgets and loading overlays
- **✏️ Font Customization** - Set custom font family for all text elements
- **🔍 Quality Detection** - Advanced blur and lighting analysis
- **👁️ Eyes Closed Detection** - Specific error message when eyes are closed during verification
- **⏸️ Pause/Resume Control** - Pause and resume camera preview and face detection
- **🎚️ Flexible Detection Modes** - Enable/disable blink or smile detection independently
- **⏱️ Photo Capture Delay** - Configurable delay before capturing photo after verification
- **🎯 Enhanced Face Centering** - Euler angle validation ensures face is looking straight at camera

## 📋 Table of Contents

- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Features](#-features)
- [Complete Configuration Reference](#-complete-configuration-reference)
- [Usage Examples](#-usage-examples)
- [Theming Examples](#-theming-examples)
- [Error Handling](#-error-handling)
- [Localization](#-localization)
- [Platform Support](#-platform-support)
- [Performance Tips](#-performance-tips)
- [Best Practices](#-best-practices)
- [Migration Guide](#-migration-guide)
- [Contributing](#-contributing)
- [License](#-license)

## 🚀 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_liveness_check: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Platform Setup

#### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for liveness verification</string>
```

Add the following to your Podfile:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      # You can remove unused permissions here
      # e.g. when you don't need camera permission, just add 'PERMISSION_CAMERA=0'
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        ## dart: PermissionGroup.camera
        'PERMISSION_CAMERA=1',
      ]
    end
  end
end
```
## 📱 Platform Support

- **iOS**: 10.0+ with Metal support
- **Android**: API level 21+ (Android 5.0)
- **Flutter**: 3.0.0 or higher
- **Dart**: 2.17 or higher
- **Camera Permissions**: Automatically requested with proper error handling
- **ML Kit**: Google ML Kit Face Detection API
- **Hardware**: Front-facing camera required

### Supported Architectures

- **Android**: arm64-v8a, armeabi-v7a, x86_64
- **iOS**: arm64, x86_64 (simulator)

## 🔄 Status Management

The package supports three main states:

- **`LivenessStatus.init`**: Shows camera preview with liveness detection
- **`LivenessStatus.success`**: Shows success asset/animation
- **`LivenessStatus.fail`**: Shows fail asset with retry button

## 🎭 Custom Assets

Replace default success/fail assets:

```dart
LivenessCheckTheme(
  successAsset: 'packages/your_package/assets/custom_success.png',
  failAsset: 'packages/your_package/assets/custom_fail.png',
)
```

## ⚡ Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

class MyLivenessCheck extends StatefulWidget {
  @override
  State<MyLivenessCheck> createState() => _MyLivenessCheckState();
}

class _MyLivenessCheckState extends State<MyLivenessCheck> {
  LivenessStatus _status = LivenessStatus.init;

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      config: LivenessCheckConfig(
        status: _status,
        appBarConfig: const AppBarConfig(
          title: 'Face Verification',
          showBackButton: true,
        ),
        callbacks: LivenessCheckCallbacks(
          onSuccess: () => setState(() => _status = LivenessStatus.success),
          onError: (error) => setState(() => _status = LivenessStatus.fail),
          onTryAgain: () => setState(() => _status = LivenessStatus.init),
        ),
      ),
    );
  }
}
```

## 🎮 Manual Camera Control

Use `LivenessCheckController` for advanced camera lifecycle management:

```dart
final controller = LivenessCheckController();

// Add controller to LivenessCheckScreen
LivenessCheckScreen(
  controller: controller,
  config: LivenessCheckConfig(...),
)

// Manual control methods
await controller.initializeCamera();  // Start camera + face detector
await controller.disposeCamera();     // Stop camera and release resources
controller.resetState();              // Reset blink count and smile status
await controller.pauseDetection();    // Pause camera preview and face detection
await controller.resumeDetection();   // Resume camera preview and face detection

// Monitor status
print(controller.isInitialized);  // Check if camera is ready
print(controller.isPaused);       // Check if camera is paused

// Listen to changes
controller.addListener(() {
  print('Camera status: ${controller.isInitialized}');
  print('Paused: ${controller.isPaused}');
});
```

### Pause/Resume Detection

Control camera preview and face detection without disposing the camera:

```dart
class _MyScreenState extends State<MyScreen> {
  final controller = LivenessCheckController();
  bool _showingDialog = false;

  Future<void> _showInstructions() async {
    // Pause detection while showing instructions
    await controller.pauseDetection();
    _showingDialog = true;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Instructions'),
        content: Text('Please position your face in the circle and blink 3 times'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );

    _showingDialog = false;
    // Resume detection after dialog closes
    await controller.resumeDetection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LivenessCheckScreen(
        controller: controller,
        config: LivenessCheckConfig(...),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInstructions,
        child: Icon(Icons.help),
      ),
    );
  }
}
```

### App Lifecycle Management Example

```dart
class _MyScreenState extends State<MyScreen> with WidgetsBindingObserver {
  final controller = LivenessCheckController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Use pauseDetection to save battery while keeping camera initialized
      controller.pauseDetection();
    } else if (state == AppLifecycleState.resumed) {
      // Resume detection when app comes back
      controller.resumeDetection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      controller: controller,
      config: LivenessCheckConfig(...),
    );
  }
}
```

## 📖 Complete Configuration Reference

### LivenessCheckConfig

Main configuration container for all customization options:

```dart
LivenessCheckConfig(
  // AppBar Configuration
  appBarConfig: AppBarConfig(),

  // UI Components
  customBottomWidget: Widget?,
  customLoadingWidget: Widget?,

  // Visual Theme
  theme: LivenessCheckTheme(),

  // Behavior Settings
  settings: LivenessCheckSettings(),

  // Text & Localization
  messages: LivenessCheckMessages(),

  // Event Callbacks
  callbacks: LivenessCheckCallbacks(),

  // Status & Loading
  status: LivenessStatus.init,
  showLoading: false,
  placeholder: "Please smile or blink eye 3 time",
)
```

### AppBarConfig - Complete AppBar Control

```dart
AppBarConfig(
  // Basic Properties
  title: 'Custom Title',
  centerTitle: true,
  backgroundColor: Colors.blue,
  elevation: 4.0,

  // Back Button Control
  showBackButton: true,           // Show/hide back button
  automaticallyImplyLeading: true, // Flutter's automatic leading
  customBackIcon: IconButton(     // Custom back widget
    icon: Icon(Icons.close),
    onPressed: () => Navigator.pop(context),
  ),

  // Text Styling
  titleStyle: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
)
```

### LivenessCheckTheme - Visual Customization

```dart
LivenessCheckTheme(
  // Colors
  backgroundColor: Colors.white,
  primaryColor: Colors.blue,
  successColor: Colors.green,
  errorColor: Colors.red,
  textColor: Colors.black,

  // Circle Styling
  borderStyle: CircleBorderStyle.solid, // or CircleBorderStyle.dashed
  borderColor: Colors.blue,
  borderWidth: 4.0,
  circleSize: 0.7, // 0.0 to 1.0
  cameraPadding: 8.0,

  // Dashed Border (when borderStyle = dashed)
  dashLength: 10.0,
  dashGap: 6.0,

  // Try Again Button Styling
  btnRetryBGColor: Colors.blue,
  btnTextRetryColor: Colors.white,
  btnRetryHeight: 44.0,              // Button height (default: 44)
  btnRetryPadding: EdgeInsets.symmetric(vertical: 16),
  btnRetryBorderRadius: 8.0,         // Border radius

  // Typography
  fontFamily: 'CustomFont',
  titleTextStyle: TextStyle(),
  messageTextStyle: TextStyle(),
  errorTextStyle: TextStyle(),
  successTextStyle: TextStyle(),

  // Assets
  successAsset: 'assets/custom_success.png',
  failAsset: 'assets/custom_fail.png',
)
```

### LivenessCheckCallbacks - Event Handling

```dart
LivenessCheckCallbacks(
  // Basic Events
  onSuccess: () {
    print('Liveness check passed!');
  },
  onError: (String errorMessage) {
    print('Error: $errorMessage');
  },
  onCancel: () {
    print('User cancelled');
  },

  // Advanced Events
  onErrorWithType: (LivenessCheckError errorType, String message) {
    switch (errorType) {
      case LivenessCheckError.noFaceDetected:
        // Handle no face error
        break;
      case LivenessCheckError.cameraPermissionDenied:
        // Handle permission error
        break;
      // ... handle other error types
    }
  },

  // Photo & Progress
  onPhotoTaken: (String imagePath) {
    print('Photo saved: $imagePath');
  },
  onProgressUpdate: (int blinkCount, bool isSmiling) {
    print('Progress: $blinkCount blinks, smiling: $isSmiling');
  },

  // Retry Logic
  onTryAgain: () {
    print('User retrying');
  },
  onMaxRetryReached: (int attemptCount) {
    print('Max attempts reached: $attemptCount');
  },
)
```

### LivenessCheckSettings - Behavior Configuration

```dart
LivenessCheckSettings(
  // Liveness Requirements
  enableBlinkDetection: true,     // Enable/disable blink detection
  requiredBlinkCount: 3,          // Number of blinks required
  enableSmileDetection: true,     // Enable/disable smile detection
  enableEyesClosedCheck: true,    // Enable/disable eyes closed error detection
                                  // Note: Auto-skipped when enableBlinkDetection is true

  // UI Controls
  showProgress: true,
  showErrorMessage: true,
  showTryAgainButton: true,

  // Behavior
  autoNavigateOnSuccess: true,
  maxRetryAttempts: 3,
  processingTimeout: Duration(seconds: 30),

  // Layout
  circlePositionY: 0.38, // Vertical position (0.0 to 1.0)

  // Photo Capture
  photoCaptureDelay: Duration(milliseconds: 0), // Delay before capturing photo
)
```

### LivenessCheckMessages - Text Customization

```dart
LivenessCheckMessages(
  // AppBar
  title: 'Liveness Check',

  // Status Messages
  initializingCamera: 'Initializing camera...',
  noFaceDetected: 'No face detected. Please position your face in the circle.',
  multipleFacesDetected: 'Multiple faces detected. Only one person allowed.',
  livenessCheckPassed: 'Liveness check passed! Taking photo...',

  // Quality Messages
  moveCloserToCamera: 'Move closer to camera or hold device steady.',
  holdStill: 'Hold still. Face features not clear.',
  imageTooBlurry: 'Image too blurry. Hold device steady.',
  poorLighting: 'Poor lighting conditions.',

  // Error Messages
  failedToCapture: 'Failed to capture photo',
  cameraPermissionDenied: 'Camera permission denied',
  failedToInitializeCamera: 'Failed to initialize camera',

  // UI Text
  tryAgainButtonText: 'Try Again',
  takingPhoto: 'Taking photo...',

  // Permission Dialog Configuration
  permissionDialogConfig: PermissionDialogConfig(
    title: 'Camera Permission Required',
    message: 'Camera permission is required for liveness check. Please enable it in settings.',
    cancelButtonText: 'Cancel',
    settingsButtonText: 'Open Settings',
  ),
)
```

### PermissionDialogConfig - Permission Dialog Customization

When camera permission is permanently denied, a dialog will be shown to guide users to settings. Customize this dialog:

```dart
PermissionDialogConfig(
  title: 'Camera Access Needed',
  message: 'To verify your identity, we need access to your camera. Please enable it in your device settings.',
  cancelButtonText: 'Not Now',
  settingsButtonText: 'Go to Settings',
)
```

### CameraSettings - Config camera controller

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

## 🎯 Usage Examples

### 1. No Back Button Example

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    appBarConfig: const AppBarConfig(
      title: 'Secure Verification',
      showBackButton: false, // Hide back button
    ),
    customBottomWidget: Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Done'),
      ),
    ),
  ),
)
```

### 2. Custom Back Icon with Confirmation

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    appBarConfig: AppBarConfig(
      title: 'Identity Verification',
      showBackButton: true,
      customBackIcon: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cancel Verification?'),
              content: const Text('Are you sure you want to cancel?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close liveness screen
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
        },
      ),
    ),
  ),
)
```

### 3. Banking App Integration

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    appBarConfig: AppBarConfig(
      title: 'SecureBank Verification',
      backgroundColor: const Color(0xFF1565C0),
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      showBackButton: true,
      customBackIcon: CustomBackButton(
        onPressed: () => _handleBankingCancel(context),
      ),
    ),
    theme: const LivenessCheckTheme(
      primaryColor: Color(0xFF1565C0),
      borderStyle: CircleBorderStyle.dashed,
      fontFamily: 'Roboto',
    ),
    callbacks: LivenessCheckCallbacks(
      onErrorWithType: (errorType, message) {
        _handleBankingError(errorType, message);
      },
      onSuccess: () => _proceedToBankingApp(),
    ),
  ),
)
```

### 4. Blink-Only Detection (No Smile Required)

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    appBarConfig: const AppBarConfig(
      title: 'Quick Verification',
      showBackButton: true,
    ),
    settings: const LivenessCheckSettings(
      enableBlinkDetection: true,     // Enable blink detection
      requiredBlinkCount: 3,          // Require 3 blinks
      enableSmileDetection: false,    // Disable smile detection
      maxRetryAttempts: 3,
    ),
    placeholder: 'Please blink your eyes 3 times',
    callbacks: LivenessCheckCallbacks(
      onSuccess: () => _handleSuccess(),
    ),
  ),
)
```

### 5. Smile-Only Detection (No Blinks Required)

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    appBarConfig: const AppBarConfig(
      title: 'Smile Verification',
      showBackButton: true,
    ),
    settings: const LivenessCheckSettings(
      enableBlinkDetection: false,    // Disable blink detection
      enableSmileDetection: true,     // Enable smile detection
      maxRetryAttempts: 3,
      photoCaptureDelay: Duration(milliseconds: 500), // Wait 500ms before capture
    ),
    placeholder: 'Please smile for the camera',
    callbacks: LivenessCheckCallbacks(
      onSuccess: () => _handleSuccess(),
    ),
  ),
)
```

### 6. Eyes Closed Check (Smile-Only Mode)

```dart
// Eyes closed check is useful when blink detection is DISABLED
// Note: Automatically skipped when enableBlinkDetection is true
LivenessCheckScreen(
  config: LivenessCheckConfig(
    appBarConfig: const AppBarConfig(
      title: 'Smile Verification',
      showBackButton: true,
    ),
    settings: const LivenessCheckSettings(
      enableBlinkDetection: false,    // Disable blink detection
      enableSmileDetection: true,     // Enable smile detection
      enableEyesClosedCheck: true,    // Enable eyes closed check (useful in smile-only mode)
      maxRetryAttempts: 3,
    ),
    messages: const LivenessCheckMessages(
      eyesClosed: 'Please keep your eyes open',
    ),
    placeholder: 'Please smile with your eyes open',
    callbacks: LivenessCheckCallbacks(
      onSuccess: () => _handleSuccess(),
    ),
  ),
)
```

### 7. E-commerce KYC

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    appBarConfig: const AppBarConfig(
      title: 'Account Verification',
      showBackButton: false, // No back button for KYC
    ),
    settings: const LivenessCheckSettings(
      enableBlinkDetection: true,
      requiredBlinkCount: 2,
      enableSmileDetection: true,
      maxRetryAttempts: 5,
      photoCaptureDelay: Duration(milliseconds: 0), // Immediate capture
    ),
    theme: const LivenessCheckTheme(
      primaryColor: Color(0xFFFF6B35),
      borderStyle: CircleBorderStyle.solid,
      circleSize: 0.75,
    ),
    customBottomWidget: _buildKYCInstructions(),
    callbacks: LivenessCheckCallbacks(
      onSuccess: () => _submitKYCData(),
      onMaxRetryReached: (count) => _showKYCFailure(count),
    ),
  ),
)
```

### 7. Custom Loading Widgets

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    // Custom camera initialization loading (shown while camera starts)
    customCameraLoadingWidget: Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.purple),
            const SizedBox(height: 16),
            const Text('Initializing camera...'),
          ],
        ),
      ),
    ),

    // Custom processing overlay (shown during verification)
    showLoading: _isProcessing,
    customLoadingWidget: Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.purple),
            const SizedBox(height: 16),
            const Text(
              'Processing verification...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    ),

    callbacks: LivenessCheckCallbacks(
      onErrorWithType: (errorType, message) {
        switch (errorType) {
          case LivenessCheckError.cameraPermissionDenied:
            _showPermissionDialog();
            break;
          case LivenessCheckError.poorLighting:
            _showLightingTips();
            break;
          default:
            _showGenericError(message);
        }
      },
    ),
  ),
)
```

### 8. Custom Permission Dialog

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    messages: LivenessCheckMessages(
      permissionDialogConfig: PermissionDialogConfig(
        title: 'Camera Access Required',
        message: 'We need camera access to verify your identity. Please grant permission in your device settings.',
        cancelButtonText: 'Not Now',
        settingsButtonText: 'Open Settings',
      ),
    ),
  ),
)
```

## 🎨 Theming Examples

### Dark Theme

```dart
const LivenessCheckTheme(
  backgroundColor: Color(0xFF1E1E1E),
  primaryColor: Colors.purple,
  successColor: Colors.teal,
  errorColor: Colors.orange,
  textColor: Colors.white,
  overlayColor: Color(0xFF1E1E1E),
  borderStyle: CircleBorderStyle.dashed,
  dashLength: 12.0,
  dashGap: 8.0,
)
```

### Corporate Theme

```dart
const LivenessCheckTheme(
  backgroundColor: Color(0xFFF8F9FA),
  primaryColor: Color(0xFF1565C0),
  successColor: Color(0xFF2E7D32),
  errorColor: Color(0xFFD32F2F),
  fontFamily: 'Corporate-Font',
  borderWidth: 6,
  circleSize: 0.8,
)
```

## 🔧 Error Handling

The package provides type-safe error handling with detailed error information:

```dart
// Error Types
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
  eyesClosed,        // New: Detected when eyes are closed
  unknownError,
}

// Usage
LivenessCheckCallbacks(
  onErrorWithType: (LivenessCheckError errorType, String message) {
    // Handle specific error types
    _analytics.logError(errorType.toString(), message);
    _showUserFriendlyError(errorType);
  },
)
```

## 🌍 Localization

Easily localize all text by providing custom messages:

```dart
// Spanish Localization
const LivenessCheckMessages(
  title: 'Verificación de Vida',
  noFaceDetected: 'No se detectó rostro. Posicione su cara en el círculo.',
  multipleFacesDetected: 'Se detectaron múltiples rostros. Solo una persona.',
  eyesClosed: 'Por favor, mantenga los ojos abiertos.',  // New
  livenessCheckPassed: '¡Verificación exitosa!',
  tryAgainButtonText: 'Intentar Nuevamente',
)
```

## ⚡ Performance Tips

### Optimize for Better Performance

1. **Camera Settings**
   ```dart
   // Use medium resolution for better performance
   ResolutionPreset.medium // Default and recommended
   ```

2. **Memory Management**
   ```dart
   // Dispose properly when done
   @override
   void dispose() {
     // Liveness screen handles disposal automatically
     super.dispose();
   }
   ```

3. **Frame Processing**
   ```dart
   LivenessCheckSettings(
     processingTimeout: Duration(seconds: 20), // Adjust based on device performance
   )
   ```

4. **Quality Detection**
   - Enable quality detection to guide users for better images
   - Use appropriate lighting conditions
   - Ensure device stability during capture

### Battery Optimization

- Camera operations are automatically suspended when app goes to background
- Face detection stops when liveness check is complete
- ML Kit resources are released when screen is disposed

## 🔧 Troubleshooting

### Common Issues

#### Camera Permission Denied
```dart
LivenessCheckCallbacks(
  onErrorWithType: (errorType, message) {
    if (errorType == LivenessCheckError.cameraPermissionDenied) {
      // Guide user to settings
      _showPermissionSettingsDialog();
    }
  },
)
```

#### Poor Detection Quality
```dart
LivenessCheckCallbacks(
  onErrorWithType: (errorType, message) {
    switch (errorType) {
      case LivenessCheckError.poorLighting:
        _showLightingTips();
        break;
      case LivenessCheckError.imageBlurry:
        _showStabilityTips();
        break;
      case LivenessCheckError.moveCloserToCamera:
        _showDistanceTips();
        break;
    }
  },
)
```

#### Multiple Faces Detected
- Ensure only one person is visible in the camera frame
- Check for reflections or images in the background

### Debug Mode

Enable debug logging for development:

```dart
// Add this in your main.dart for debug builds
import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    // Debug prints are automatically enabled in the package
  }
  runApp(MyApp());
}
```

## 🚨 Migration Guide

If upgrading from a version that used `customHeader`, replace it with `appBarConfig`:

```dart
// Before
LivenessCheckConfig(
  customHeader: AppBar(title: Text('Custom')),
)

// After
LivenessCheckConfig(
  appBarConfig: AppBarConfig(
    title: 'Custom',
    showBackButton: true,
  ),
)
```