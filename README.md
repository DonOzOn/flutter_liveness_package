# Flutter Liveness Check Package

A comprehensive Flutter package for face liveness detection with customizable UI, status management, and advanced features like dashed borders, retry limits, and asset replacement.

## ( Features

- **<� Real-time Face Detection** - ML Kit powered liveness verification
- **<� Customizable Circle Styles** - Solid and dashed border options with camera padding
- **=� Status Management** - Init, success, and fail states with asset replacement
- **= Retry Logic** - Configurable maximum attempts with callbacks
- **< Localization Support** - Customizable messages and button text
- **� Flexible Configuration** - Comprehensive theme and behavior customization
- **=� Custom Widgets** - Custom headers and bottom widgets support
- **<� Font Customization** - Set custom font family for all text elements

## =� Quick Start

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

## =� Complete Parameter Reference

### LivenessCheckConfig

Main configuration class containing all customization options:

```dart
LivenessCheckConfig({
  Widget? customHeader,              // Custom header widget
  Widget? customBottomWidget,        // Custom bottom widget
  LivenessCheckTheme theme,          // Visual theme configuration
  LivenessCheckCallbacks? callbacks, // Event callbacks
  LivenessCheckMessages messages,    // Custom text messages
  LivenessCheckSettings settings,    // Behavior settings
  String? placeholder,               // Main instruction text
  LivenessStatus status,             // Current status (init/success/fail)
  bool showLoading,                  // Show loading overlay (dynamic control)
  Widget? customLoadingWidget,       // Custom loading widget (replaces default overlay)
})
```

### LivenessCheckTheme

Controls visual appearance and styling:

```dart
LivenessCheckTheme({
  // Colors
  Color backgroundColor,             // Screen background (default: Colors.white)
  Color primaryColor,               // Primary accent color (default: Colors.blue)
  Color successColor,               // Success state color (default: Colors.green)
  Color errorColor,                 // Error state color (default: Colors.red)
  Color warningColor,               // Warning state color (default: Colors.orange)
  Color borderColor,                // Initial border color (default: Colors.blue)
  Color textColor,                  // Text color (default: Colors.black)
  Color overlayColor,               // Camera overlay color (default: Colors.white)

  // Circle Configuration
  double circleSize,                // Circle size ratio (default: 0.65)
  double borderWidth,               // Border thickness (default: 4)
  CircleBorderStyle borderStyle,    // Border style: solid or dashed (default: solid)
  double dashLength,                // Dash length for dashed style (default: 8.0)
  double dashGap,                   // Gap between dashes (default: 8.0)
  double cameraPadding,             // Space between border and camera (default: 0.0)

  // Assets
  String? successAsset,             // Custom success image path
  String? failAsset,                // Custom fail image path

  // Typography
  String? fontFamily,               // Font family for all text
  TextStyle? titleTextStyle,        // Custom title style
  TextStyle? messageTextStyle,      // Custom message style
  TextStyle? errorTextStyle,        // Custom error style
  TextStyle? successTextStyle,      // Custom success style
})
```

### LivenessCheckSettings

Controls behavior and requirements:

```dart
LivenessCheckSettings({
  int requiredBlinkCount,           // Number of blinks required (default: 3)
  bool requireSmile,                // Whether smile is required (default: false)
  bool showProgress,                // Show progress indicators (default: true)
  bool autoNavigateOnSuccess,       // Auto-navigate after success (default: true)
  bool showErrorMessage,            // Show error messages (default: true)
  bool showTryAgainButton,          // Show try again button on fail (default: true)
  int maxRetryAttempts,            // Maximum retry attempts (default: 3)
  Duration processingTimeout,       // Processing timeout (default: 30 seconds)
  double circlePositionY,          // Vertical circle position (default: 0.38)
})
```

### LivenessCheckCallbacks

Handle events and custom logic:

```dart
LivenessCheckCallbacks({
  VoidCallback? onSuccess,                              // Liveness check passed
  Function(String error)? onError,                      // Error occurred
  Function(dynamic errorType, String message)? onErrorWithType, // Detailed error
  VoidCallback? onCancel,                               // User cancelled
  Function(String imagePath)? onPhotoTaken,             // Photo captured
  Function(int blinkCount, bool isSmiling)? onProgressUpdate, // Progress update
  VoidCallback? onTryAgain,                             // Try again pressed
  Function(int attemptCount)? onMaxRetryReached,        // Max retries reached
})
```

### LivenessCheckMessages

Customize all user-facing text:

```dart
LivenessCheckMessages({
  String title,                     // Screen title (default: 'Liveness Check')
  String initializingCamera,        // Camera init message
  String noFaceDetected,           // No face detected message
  String multipleFacesDetected,    // Multiple faces message
  String moveCloserToCamera,       // Move closer message
  String holdStill,                // Hold still message
  String imageTooBlurry,           // Image blurry message
  String poorLighting,             // Poor lighting message
  String livenessCheckPassed,      // Success message
  String takingPhoto,              // Taking photo message
  String failedToCapture,          // Capture failed message
  String cameraPermissionDenied,   // Permission denied message
  String failedToInitializeCamera, // Init failed message
  String tryAgainButtonText,       // Try again button text (default: 'Try Again')
})
```

## <� Circle Style Examples

### Figma-Style Dashed Circle

```dart
LivenessCheckConfig(
  theme: const LivenessCheckTheme(
    borderStyle: CircleBorderStyle.dashed,
    borderColor: Color(0xFF35C659), // Green color
    borderWidth: 4,
    dashLength: 8,
    dashGap: 8,
    cameraPadding: 10,
    circleSize: 0.65,
  ),
  placeholder: "Please adjust your face until the circle turns green",
)
```

### Solid Circle with Padding

```dart
LivenessCheckConfig(
  theme: const LivenessCheckTheme(
    borderStyle: CircleBorderStyle.solid,
    borderColor: Colors.blue,
    borderWidth: 3,
    cameraPadding: 20, // 20px padding around camera
    circleSize: 0.7,
  ),
)
```

## = Status Management

The package supports three main states:

### Init Status (Camera Active)
```dart
LivenessCheckConfig(
  status: LivenessStatus.init,
  // Camera is active and face detection is running
)
```

### Success Status (Asset Replacement)
```dart
LivenessCheckConfig(
  status: LivenessStatus.success,
  theme: const LivenessCheckTheme(
    successAsset: 'assets/custom_success.png',
    // If no asset provided, uses default package asset
  ),
  placeholder: "Liveness check successful!",
)
```

### Fail Status (Asset + Try Again Button)
```dart
LivenessCheckConfig(
  status: LivenessStatus.fail,
  theme: const LivenessCheckTheme(
    failAsset: 'assets/custom_fail.png',
    // If no asset provided, uses default package asset
  ),
  settings: const LivenessCheckSettings(
    showTryAgainButton: true,
    maxRetryAttempts: 3,
  ),
  callbacks: LivenessCheckCallbacks(
    onTryAgain: () {
      // Reset to init status
    },
    onMaxRetryReached: (attemptCount) {
      // Handle max retry limit
    },
  ),
)
```

## < Localization Example

```dart
LivenessCheckConfig(
  messages: const LivenessCheckMessages(
    title: 'X�c th�c khu�n m�t',
    tryAgainButtonText: 'Th� l�i',
    noFaceDetected: 'Kh�ng ph�t hi�n khu�n m�t. Vui l�ng �a m�t v�o v�ng tr�n.',
    multipleFacesDetected: 'Ph�t hi�n nhi�u khu�n m�t. Ch� cho ph�p m�t ng��i.',
    moveCloserToCamera: 'Di chuy�n g�n camera h�n.',
    holdStill: 'Gi� y�n. �c i�m khu�n m�t kh�ng r� r�ng.',
    livenessCheckPassed: 'X�c th�c th�nh c�ng! ang ch�p �nh...',
  ),
  placeholder: "Vui l�ng i�u ch�nh khu�n m�t cho �n khi v�ng tr�n chuy�n xanh",
)
```

## <� Advanced Features

### Custom Font Family

```dart
LivenessCheckConfig(
  theme: const LivenessCheckTheme(
    fontFamily: 'Roboto', // Applied to all text elements
    borderColor: Colors.purple,
  ),
)
```

### Hide UI Elements

```dart
LivenessCheckConfig(
  showLoading: false,                // Hide loading indicator (dynamic control)
  settings: const LivenessCheckSettings(
    showErrorMessage: false,        // Hide error messages
    showTryAgainButton: false,     // Hide try again button
  ),
)
```

### Dynamic Loading Control

```dart
class MyLivenessCheck extends StatefulWidget {
  @override
  State<MyLivenessCheck> createState() => _MyLivenessCheckState();
}

class _MyLivenessCheckState extends State<MyLivenessCheck> {
  LivenessStatus _status = LivenessStatus.init;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      config: LivenessCheckConfig(
        status: _status,
        showLoading: _isProcessing, // Dynamic control from parent
        callbacks: LivenessCheckCallbacks(
          onSuccess: () {
            setState(() => _isProcessing = true); // Show loading during processing
            // Process the result
            Future.delayed(Duration(seconds: 2), () {
              setState(() {
                _status = LivenessStatus.success;
                _isProcessing = false; // Hide loading when done
              });
            });
          },
        ),
      ),
    );
  }
}
```

### Custom Widgets

```dart
LivenessCheckConfig(
  customHeader: MyCustomHeader(),
  customBottomWidget: MyCustomFooter(),
  customLoadingWidget: MyCustomLoadingWidget(), // Custom loading overlay
  settings: const LivenessCheckSettings(
    // When using customBottomWidget, consider disabling try again button
    showTryAgainButton: false,
  ),
)
```

### Custom Loading Widget

```dart
class MyCustomLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.withValues(alpha: 0.8), // Custom background
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom animated loading indicator
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Processing your verification...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait a moment',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Usage example
LivenessCheckConfig(
  showLoading: true,
  customLoadingWidget: MyCustomLoadingWidget(),
  // ... other parameters
)
```

### Retry Limits

```dart
LivenessCheckConfig(
  settings: const LivenessCheckSettings(
    maxRetryAttempts: 5,
  ),
  callbacks: LivenessCheckCallbacks(
    onMaxRetryReached: (attemptCount) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Too many attempts'),
          content: Text('Failed after $attemptCount attempts'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    },
  ),
)
```

## =� Sample Code

For complete working examples, check the [sample folder](lib/sample/):

- **[basic_liveness_example.dart](lib/sample/basic_liveness_example.dart)** - Simple implementation
- **[figma_style_example.dart](lib/sample/figma_style_example.dart)** - Dashed circle with Vietnamese localization
- **[custom_assets_example.dart](lib/sample/custom_assets_example.dart)** - Custom success/fail assets
- **[custom_widget_example.dart](lib/sample/custom_widget_example.dart)** - Advanced UI with custom widgets
- **[custom_loading_example.dart](lib/sample/custom_loading_example.dart)** - Custom loading widget with animations
- **[minimal_example.dart](lib/sample/minimal_example.dart)** - Minimal configuration for testing

Each example demonstrates different aspects of the package and can be run independently.

## =' Integration Patterns

### Navigation Integration
```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MyLivenessCheck(),
  ),
);

if (result == true) {
  // Liveness check passed
} else {
  // Liveness check failed or cancelled
}
```

### Form Integration
```dart
class RegistrationFlow extends StatefulWidget {
  // Include liveness check as step in multi-step form
  // See custom_widget_example.dart for reference
}
```

## =� Default Assets

The package includes default success and fail assets:
- `packages/flutter_liveness_check/assets/success.png`
- `packages/flutter_liveness_check/assets/fail.png`

These are automatically used when no custom assets are provided.

## <� Best Practices

1. **State Management**: Always manage `LivenessStatus` in parent widget
2. **Resource Management**: Camera automatically starts/stops based on status
3. **Error Handling**: Implement comprehensive callbacks for better UX
4. **Custom Assets**: Use appropriate sizes (recommended: 200x200px)
5. **Retry Limits**: Set reasonable max attempts (3-5) to prevent frustration
6. **Localization**: Customize all messages for international apps
7. **Testing**: Test with different lighting conditions and devices

## =� Requirements

- Flutter SDK: >=3.8.1
- Dart SDK: >=3.0.0
- iOS: 11.0+
- Android: API level 21+

## = Permissions

The package automatically requests camera permission. Ensure your app has camera usage descriptions:

### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for face verification</string>
```

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

## <� Migration Guide

### From Basic Implementation
```dart
// Before
LivenessCheckScreen()

// After - same behavior
LivenessCheckScreen(
  config: LivenessCheckConfig(
    status: LivenessStatus.init,
  ),
)
```

### Adding Custom Styling
```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    status: _currentStatus,
    theme: const LivenessCheckTheme(
      borderStyle: CircleBorderStyle.dashed,
      borderColor: Color(0xFF35C659),
      fontFamily: 'YourFont',
    ),
    callbacks: LivenessCheckCallbacks(
      onTryAgain: () => setState(() => _currentStatus = LivenessStatus.init),
    ),
  ),
)
```