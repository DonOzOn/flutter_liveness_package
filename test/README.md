# Flutter Liveness Check - Test Suite

This directory contains comprehensive tests for the Flutter Liveness Check package.

## Test Structure

### 📋 Test Files Overview

1. **[liveness_check_config_test.dart](liveness_check_config_test.dart)**
   - Configuration classes testing (LivenessCheckConfig, LivenessCheckTheme, LivenessCheckSettings, etc.)
   - Default values validation
   - Custom configuration testing
   - Enum validation
   - Callback functionality

2. **[liveness_check_screen_test.dart](liveness_check_screen_test.dart)**
   - Widget rendering tests
   - UI component visibility tests
   - User interaction testing (try again button, etc.)
   - Status change handling
   - Custom widget integration

3. **[widget/dashed_circle_painter_test.dart](widget/dashed_circle_painter_test.dart)**
   - Custom painter functionality
   - Dash pattern rendering
   - Different stroke widths and colors
   - Size handling
   - Repaint optimization

4. **[integration_test.dart](integration_test.dart)**
   - Full workflow simulation
   - Status transition testing
   - Loading states integration
   - Custom widgets integration
   - Theme and localization integration

5. **[error_handling_test.dart](error_handling_test.dart)**
   - Error message handling
   - Custom error messages
   - Retry logic testing
   - Edge cases and extreme configurations
   - Null safety validation

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/liveness_check_config_test.dart
flutter test test/liveness_check_screen_test.dart
flutter test test/widget/dashed_circle_painter_test.dart
flutter test test/integration_test.dart
flutter test test/error_handling_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Generate Coverage Report
```bash
# Install lcov (on macOS)
brew install lcov

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

## Test Categories

### 🔧 Unit Tests
- Configuration validation
- Error handling logic
- Custom painter functionality
- Callback mechanisms
- Enum and constant values

### 🎯 Widget Tests
- UI component rendering
- User interaction testing
- State management
- Dynamic parameter updates
- Custom widget integration

### 🔄 Integration Tests
- Complete workflow simulation
- Multi-component interactions
- Status transitions
- Theme and localization
- Loading states

### 🚨 Error & Edge Case Tests
- Invalid configurations
- Null safety
- Extreme values
- Error message customization
- Retry limit handling

## Test Coverage Goals

- **Configuration Classes**: 100% coverage of all parameters and methods
- **UI Components**: All visible elements and interactions
- **State Management**: All status transitions and updates
- **Error Handling**: All error types and scenarios
- **Custom Widgets**: All custom implementations
- **Localization**: Multiple language support

## Best Practices

### Writing Tests
1. **Descriptive Names**: Use clear, descriptive test names that explain what is being tested
2. **Arrange-Act-Assert**: Structure tests with clear setup, execution, and verification phases
3. **Test Isolation**: Each test should be independent and not rely on other tests
4. **Edge Cases**: Include tests for boundary conditions and error scenarios

### Widget Testing
1. **Pump Widgets**: Always use `tester.pumpWidget()` to render widgets
2. **Find Elements**: Use appropriate finders (`find.byType`, `find.text`, etc.)
3. **User Interactions**: Test user interactions with `tester.tap()`, `tester.drag()`, etc.
4. **Async Operations**: Handle async operations with `tester.pump()` and `tester.pumpAndSettle()`

### Integration Testing
1. **Realistic Scenarios**: Test complete user workflows
2. **State Changes**: Verify state transitions work correctly
3. **Cross-Component**: Test interactions between different components
4. **Performance**: Consider performance implications of complex scenarios

## Common Test Patterns

### Testing Configuration Classes
```dart
test('should create config with custom values', () {
  final config = LivenessCheckConfig(
    status: LivenessStatus.success,
    showLoading: true,
  );

  expect(config.status, LivenessStatus.success);
  expect(config.showLoading, true);
});
```

### Testing Widget Rendering
```dart
testWidgets('should display custom header when provided', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: LivenessCheckScreen(
        config: LivenessCheckConfig(
          customHeader: Text('Custom Header'),
        ),
      ),
    ),
  );

  expect(find.text('Custom Header'), findsOneWidget);
});
```

### Testing User Interactions
```dart
testWidgets('should call callback when button pressed', (WidgetTester tester) async {
  bool callbackCalled = false;

  await tester.pumpWidget(/* widget setup */);
  await tester.tap(find.text('Try Again'));
  await tester.pump();

  expect(callbackCalled, true);
});
```

### Testing State Changes
```dart
testWidgets('should handle status changes', (WidgetTester tester) async {
  // Test initial state
  const config1 = LivenessCheckConfig(status: LivenessStatus.init);
  await tester.pumpWidget(MaterialApp(home: LivenessCheckScreen(config: config1)));

  // Test state change
  const config2 = LivenessCheckConfig(status: LivenessStatus.success);
  await tester.pumpWidget(MaterialApp(home: LivenessCheckScreen(config: config2)));

  expect(find.byType(LivenessCheckScreen), findsOneWidget);
});
```

## Continuous Integration

Tests should be run automatically in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - run: flutter test --reporter json > test_results.json
```

## Debugging Tests

### Running Single Test
```bash
flutter test test/liveness_check_config_test.dart -n "should create config with default values"
```

### Debug Mode
```bash
flutter test --start-paused
```

### Verbose Output
```bash
flutter test --verbose
```

## Contributing

When adding new features:

1. **Write Tests First**: Consider using TDD (Test-Driven Development)
2. **Cover Edge Cases**: Include tests for error conditions and boundary cases
3. **Update Documentation**: Update this README when adding new test categories
4. **Run All Tests**: Ensure existing tests still pass
5. **Check Coverage**: Maintain high test coverage

## Test Data

For consistent testing, use these standard test configurations:

```dart
// Standard test theme
const testTheme = LivenessCheckTheme(
  borderStyle: CircleBorderStyle.dashed,
  borderColor: Colors.green,
  primaryColor: Colors.blue,
);

// Standard test settings
const testSettings = LivenessCheckSettings(
  requiredBlinkCount: 3,
  maxRetryAttempts: 3,
  showTryAgainButton: true,
);

// Standard test messages
const testMessages = LivenessCheckMessages(
  title: 'Test Liveness Check',
  tryAgainButtonText: 'Test Try Again',
);
```

This ensures consistency across tests and makes them easier to maintain.