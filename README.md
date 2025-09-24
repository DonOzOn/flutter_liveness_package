# Flutter Liveness Check Package

A comprehensive Flutter package for face liveness detection with fully customizable UI, AppBar configuration, error handling, and advanced features like dashed borders, retry limits, and asset replacement.

## ✨ Features

- **📷 Real-time Face Detection** - ML Kit powered liveness verification
- **🎨 Fully Customizable UI** - Comprehensive theming and styling options
- **🔧 Flexible AppBar** - Custom titles, back buttons, and complete AppBar control
- **📊 Status Management** - Init, success, and fail states with asset replacement
- **🔄 Retry Logic** - Configurable maximum attempts with callbacks
- **🌍 Localization Support** - Customizable messages and button text
- **🎯 Error Handling** - Type-safe error enums with detailed error information
- **🎭 Custom Widgets** - Custom bottom widgets and loading overlays
- **✏️ Font Customization** - Set custom font family for all text elements
- **🔍 Quality Detection** - Advanced blur and lighting analysis

## 🚀 Quick Start

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

  // Button Colors
  btnRetryBGColor: Colors.blue,
  btnTextRetryColor: Colors.white,

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
  requiredBlinkCount: 3,
  requireSmile: false,

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

### 4. E-commerce KYC

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    appBarConfig: const AppBarConfig(
      title: 'Account Verification',
      showBackButton: false, // No back button for KYC
    ),
    settings: const LivenessCheckSettings(
      requiredBlinkCount: 2,
      requireSmile: true,
      maxRetryAttempts: 5,
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

### 5. Custom Loading & Error Handling

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    showLoading: _isProcessing,
    customLoadingWidget: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: Colors.purple),
        const SizedBox(height: 16),
        const Text('Processing verification...'),
      ],
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
  livenessCheckPassed: '¡Verificación exitosa!',
  tryAgainButtonText: 'Intentar Nuevamente',
)
```

## 📱 Platform Support

- **iOS**: 10.0+
- **Android**: API level 21+
- **Camera Permissions**: Automatically handled
- **ML Kit**: Face Detection API

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

## 📋 Best Practices

1. **Always handle errors**: Implement `onErrorWithType` for better user experience
2. **Provide clear instructions**: Use custom bottom widgets for user guidance
3. **Test different lighting**: Use quality detection callbacks to guide users
4. **Customize for your brand**: Use consistent colors and fonts with your app
5. **Handle permissions**: Gracefully handle camera permission denials
6. **Accessibility**: Ensure custom widgets follow accessibility guidelines

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

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests.

## 📄 License

This package is released under the MIT License. See LICENSE file for details.

---

**Made with ❤️ by the Flutter Community**