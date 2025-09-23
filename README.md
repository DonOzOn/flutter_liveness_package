# Customizable Liveness Check Screen

The `LivenessCheckScreen` has been enhanced to be fully customizable and reusable across any Flutter project. You can now customize the header, bottom widget, colors, text messages, and behavior through a comprehensive configuration system.

## Features

- **🎨 Custom Themes**: Customize colors, text styles, and UI elements
- **📱 Custom Header**: Replace the default app bar with your own widget
- **⬇️ Custom Bottom Widget**: Add custom actions, tips, or branding
- **🔄 Flexible Callbacks**: Handle success, error, and progress events
- **⚙️ Configurable Settings**: Adjust blink requirements, smile detection, and more
- **🌐 Custom Messages**: Localize or customize all user-facing text

## Quick Start

### Basic Usage (Default Configuration)

```dart
import 'package:flutter_liveness_check/liveness_check_screen.dart';

// Simple usage with default settings
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LivenessCheckScreen(),
  ),
);
```

### Custom Theme

```dart
import 'package:flutter_liveness_check/liveness_check_screen.dart';
import 'package:flutter_liveness_check/liveness_check_config.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LivenessCheckScreen(
      config: LivenessCheckConfig(
        theme: const LivenessCheckTheme(
          backgroundColor: Color(0xFF1E1E1E), // Dark background
          primaryColor: Colors.purple,         // Purple accent
          successColor: Colors.teal,          // Teal success
          errorColor: Colors.orange,          // Orange errors
          textColor: Colors.white,            // White text
          circleSize: 0.8,                    // Larger circle
          borderWidth: 6,                     // Thicker border
        ),
        messages: const LivenessCheckMessages(
          title: 'Face Verification',
          noFaceDetected: 'Position your face within the circle',
          livenessCheckPassed: 'Verification successful!',
        ),
      ),
    ),
  ),
);
```

## Configuration Options

### LivenessCheckConfig

The main configuration class that contains all customization options:

```dart
LivenessCheckConfig(
  customHeader: Widget?,              // Custom header widget
  customBottomWidget: Widget?,        // Custom bottom widget
  theme: LivenessCheckTheme,          // Visual theme configuration
  callbacks: LivenessCheckCallbacks?, // Event callbacks
  messages: LivenessCheckMessages,    // Custom text messages
  settings: LivenessCheckSettings,    // Behavior settings
)
```

### LivenessCheckTheme

Controls the visual appearance:

```dart
LivenessCheckTheme(
  backgroundColor: Colors.white,      // Screen background
  primaryColor: Colors.blue,          // Primary accent color
  successColor: Colors.green,         // Success state color
  errorColor: Colors.red,             // Error state color
  warningColor: Colors.orange,        // Warning state color
  borderColor: Colors.blue,           // Initial border color
  textColor: Colors.black,            // Text color
  overlayColor: Colors.white,         // Camera overlay color
  circleSize: 0.7,                    // Circle size (0.0 - 1.0)
  borderWidth: 4,                     // Border thickness
  titleTextStyle: TextStyle?,         // Custom title style
  messageTextStyle: TextStyle?,       // Custom message style
  errorTextStyle: TextStyle?,         // Custom error style
  successTextStyle: TextStyle?,       // Custom success style
)
```

### LivenessCheckCallbacks

Handle events and custom navigation:

```dart
LivenessCheckCallbacks(
  onSuccess: () {
    // Called when liveness check passes
    print('Verification successful!');
  },
  onError: (String error) {
    // Called when an error occurs
    print('Error: $error');
  },
  onCancel: () {
    // Called when user cancels
    print('User cancelled');
  },
  onPhotoTaken: (String imagePath) {
    // Called when photo is captured
    print('Photo saved: $imagePath');
  },
  onProgressUpdate: (int blinkCount, bool isSmiling) {
    // Called during liveness detection
    print('Progress: $blinkCount blinks, smiling: $isSmiling');
  },
)
```

### LivenessCheckMessages

Customize all user-facing text:

```dart
LivenessCheckMessages(
  title: 'Liveness Check',
  initializingCamera: 'Initializing camera...',
  noFaceDetected: 'No face detected. Please position your face in the circle.',
  multipleFacesDetected: 'Multiple faces detected. Only one person allowed.',
  moveCloserToCamera: 'Move closer to camera or hold device steady.',
  holdStill: 'Hold still. Face features not clear.',
  imageTooBlurry: 'Image too blurry. Hold device steady.',
  poorLighting: 'Poor lighting conditions.',
  livenessCheckPassed: 'Liveness check passed! Taking photo...',
  takingPhoto: 'Taking photo...',
  failedToCapture: 'Failed to capture photo',
  cameraPermissionDenied: 'Camera permission denied',
  failedToInitializeCamera: 'Failed to initialize camera',
)
```

### LivenessCheckSettings

Control behavior and requirements:

```dart
LivenessCheckSettings(
  requiredBlinkCount: 3,              // Number of blinks required
  requireSmile: false,                // Whether smile is required
  showProgress: true,                 // Show progress indicators
  autoNavigateOnSuccess: true,        // Auto-navigate after success
  processingTimeout: Duration(seconds: 30), // Processing timeout
  circlePositionY: 0.4,              // Vertical position of circle
)
```

## Examples

### Banking App Integration

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    // Custom header with banking branding
    customHeader: Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Bank logo and title
          const Text(
            'Secure Banking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Security message
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Identity Verification Required',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),

    // Banking theme colors
    theme: const LivenessCheckTheme(
      backgroundColor: Color(0xFFF8F9FA),
      primaryColor: Color(0xFF1565C0),
      successColor: Color(0xFF2E7D32),
      errorColor: Color(0xFFD32F2F),
    ),

    // Custom verification flow
    settings: const LivenessCheckSettings(
      requiredBlinkCount: 3,
      requireSmile: false,
      autoNavigateOnSuccess: false,
    ),

    // Handle banking-specific logic
    callbacks: LivenessCheckCallbacks(
      onSuccess: () => _showBankingSuccessDialog(),
      onError: (error) => _showBankingErrorDialog(error),
      onPhotoTaken: (imagePath) => _processBankingVerification(imagePath),
    ),
  ),
)
```

### E-commerce KYC

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    // E-commerce branding
    customHeader: _buildEcommerceHeader(),
    customBottomWidget: _buildEcommerceTips(),

    // Brand colors
    theme: const LivenessCheckTheme(
      primaryColor: Color(0xFFFF6B35),
      successColor: Color(0xFF4CAF50),
      circleSize: 0.75,
    ),

    // Quick verification
    settings: const LivenessCheckSettings(
      requiredBlinkCount: 2,
      requireSmile: true,
      showProgress: true,
    ),

    callbacks: LivenessCheckCallbacks(
      onPhotoTaken: (imagePath) {
        // Upload to KYC service
        _uploadToKYCService(imagePath);
      },
    ),
  ),
)
```

### Healthcare App

```dart
LivenessCheckScreen(
  config: LivenessCheckConfig(
    theme: const LivenessCheckTheme(
      backgroundColor: Color(0xFFF0F8F7),
      primaryColor: Color(0xFF00695C),
      successColor: Color(0xFF4CAF50),
      textColor: Color(0xFF263238),
    ),

    messages: const LivenessCheckMessages(
      title: 'Patient Verification',
      noFaceDetected: 'Please position your face for verification',
      livenessCheckPassed: 'Patient identity verified',
    ),

    settings: const LivenessCheckSettings(
      requiredBlinkCount: 2,
      requireSmile: false,
      showProgress: false,
    ),

    callbacks: LivenessCheckCallbacks(
      onSuccess: () => _proceedToHealthcareApp(),
      onPhotoTaken: (imagePath) => _savePatientPhoto(imagePath),
    ),
  ),
)
```

## Custom Header Examples

### Branded Header with Logo

```dart
Widget _buildBrandedHeader() {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Image.asset('assets/logo.png', height: 32),
              ),
            ),
            SizedBox(width: 48),
          ],
        ),
        SizedBox(height: 16),
        Text(
          'Secure Identity Verification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
```

### Progress Header

```dart
Widget _buildProgressHeader() {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        SizedBox(height: 40),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                'Step 2 of 3',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(width: 48),
          ],
        ),
        SizedBox(height: 16),
        LinearProgressIndicator(value: 0.66),
        SizedBox(height: 16),
        Text(
          'Face Verification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
```

## Custom Bottom Widget Examples

### Action Buttons

```dart
Widget _buildActionButtons() {
  return Container(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _retryVerification(),
            child: Text('Retry'),
          ),
        ),
      ],
    ),
  );
}
```

### Help & Tips

```dart
Widget _buildHelpSection() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      border: Border(top: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Column(
      crossAxisSize: CrossAxisSize.start,
      children: [
        Text(
          'Verification Tips:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 12),
        _buildTip(Icons.lightbulb_outline, 'Ensure good lighting'),
        _buildTip(Icons.center_focus_strong, 'Center your face in the circle'),
        _buildTip(Icons.phone_android, 'Hold your device steady'),
        SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => _showDetailedHelp(),
            child: Text('Need help?'),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTip(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    ),
  );
}
```

## Best Practices

1. **Consistent Branding**: Use your app's color scheme and typography
2. **Clear Instructions**: Provide helpful guidance in custom headers/bottoms
3. **Error Handling**: Implement proper error callbacks for user feedback
4. **Accessibility**: Ensure custom widgets follow accessibility guidelines
5. **Performance**: Keep custom widgets lightweight for smooth camera performance
6. **Testing**: Test with different device orientations and lighting conditions

## Migration from Default Screen

If you're currently using the default `LivenessCheckScreen`, migration is simple:

```dart
// Before
LivenessCheckScreen()

// After (same behavior)
LivenessCheckScreen(config: LivenessCheckConfig())

// Or with minimal customization
LivenessCheckScreen(
  config: LivenessCheckConfig(
    theme: LivenessCheckTheme(
      primaryColor: YourBrandColors.primary,
    ),
    callbacks: LivenessCheckCallbacks(
      onPhotoTaken: (imagePath) {
        // Your custom photo handling
      },
    ),
  ),
)
```

The screen maintains full backward compatibility while providing extensive customization options for your specific use case.