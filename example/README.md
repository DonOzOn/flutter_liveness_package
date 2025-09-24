# Flutter Liveness Check - Sample Code

This directory contains sample implementations demonstrating various usage patterns of the Flutter Liveness Check package.

## Examples Overview

### 1. [Basic Liveness Example](basic_liveness_example.dart)
- Simple implementation with default settings
- Shows basic callback handling
- Good starting point for new implementations

### 2. [Figma Style Example](figma_style_example.dart)
- Demonstrates dashed circle border style
- Vietnamese language localization
- Custom colors matching Figma design
- Max retry attempts with dialog handling

### 3. [Custom Assets Example](custom_assets_example.dart)
- Shows how to use custom success/fail assets
- Interactive state testing buttons
- Custom retry limits and progress tracking
- Comprehensive callback demonstrations

### 4. [Custom Widget Example](custom_widget_example.dart)
- Custom header with progress indicators
- Custom bottom widget with instructions
- Complex UI integration
- Professional verification flow

### 5. [Minimal Example](minimal_example.dart)
- Minimal configuration for quick setup
- All states demo with menu switcher
- Perfect for testing and prototyping

### 6. [Custom Loading Example](custom_loading_example.dart)
- Custom loading widget with animations
- Progress step indicators
- Dynamic loading control with test buttons
- Professional branded loading overlay

## Key Features Demonstrated

### Circle Styling
```dart
theme: const LivenessCheckTheme(
  borderStyle: CircleBorderStyle.dashed,
  borderColor: Color(0xFF35C659),
  dashLength: 8,
  dashGap: 8,
  cameraPadding: 10,
),
```

### Status Management
```dart
LivenessStatus _status = LivenessStatus.init;

// In callbacks:
onSuccess: () => setState(() => _status = LivenessStatus.success),
onError: (error) => setState(() => _status = LivenessStatus.fail),
onTryAgain: () => setState(() => _status = LivenessStatus.init),
```

### Custom Assets
```dart
theme: const LivenessCheckTheme(
  successAsset: 'assets/custom_success.png',
  failAsset: 'assets/custom_fail.png',
),
```

### Retry Limits
```dart
settings: const LivenessCheckSettings(
  maxRetryAttempts: 3,
),
callbacks: LivenessCheckCallbacks(
  onMaxRetryReached: (attemptCount) {
    // Handle max attempts reached
  },
),
```

### Localization
```dart
messages: const LivenessCheckMessages(
  title: 'Xác thực khuôn mặt',
  tryAgainButtonText: 'Thử lại',
  noFaceDetected: 'Không phát hiện khuôn mặt...',
),
```

### Custom Widgets
```dart
LivenessCheckConfig(
  customHeader: YourCustomHeaderWidget(),
  customBottomWidget: YourCustomBottomWidget(),
  customLoadingWidget: YourCustomLoadingWidget(),
  settings: const LivenessCheckSettings(
    showTryAgainButton: false, // When using customBottomWidget
  ),
),
```

### Custom Loading Widget
```dart
customLoadingWidget: Container(
  color: Colors.blue.withValues(alpha: 0.9),
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 16),
        Text('Processing...', style: TextStyle(color: Colors.white)),
      ],
    ),
  ),
),
```

## Usage Tips

1. **State Management**: Always manage `LivenessStatus` in parent widget
2. **Asset Paths**: Use `packages/flutter_liveness_check/assets/` for default assets
3. **Custom Widgets**: When using `customBottomWidget`, consider setting `showTryAgainButton: false`
4. **Retry Logic**: Implement proper max retry handling for better UX
5. **Localization**: Customize all messages for international apps

## Integration Patterns

### Basic Integration
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BasicLivenessExample(),
    );
  }
}
```

### Navigation Integration
```dart
// Navigate to liveness check
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => FigmaStyleExample(),
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
  // Use CustomWidgetExample as reference
}
```

## Performance Notes

- Camera is automatically managed based on status
- Resources are disposed when status changes away from `init`
- Use appropriate retry limits to prevent resource exhaustion
- Consider loading states for better user experience

## Testing

Run the minimal example for quick testing:
```bash
flutter run lib/sample/minimal_example.dart
```

Each example can be run independently for specific feature testing.