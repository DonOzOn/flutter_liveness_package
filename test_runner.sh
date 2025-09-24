#!/bin/bash

# Flutter Liveness Check - Test Runner Script
# This script runs all tests with coverage and generates reports

set -e

echo "🧪 Flutter Liveness Check - Test Suite"
echo "======================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Navigate to project directory
cd "$(dirname "$0")"

echo ""
echo "📦 Getting dependencies..."
flutter pub get

echo ""
echo "🔍 Analyzing code..."
flutter analyze

echo ""
echo "🧪 Running all tests..."
flutter test

echo ""
echo "📊 Running tests with coverage..."
flutter test --coverage

# Check if lcov is available for HTML coverage report
if command -v lcov &> /dev/null && command -v genhtml &> /dev/null; then
    echo ""
    echo "📈 Generating HTML coverage report..."

    # Create coverage directory if it doesn't exist
    mkdir -p coverage/html

    # Generate HTML coverage report
    genhtml coverage/lcov.info -o coverage/html --ignore-errors source

    echo "✅ Coverage report generated at: coverage/html/index.html"
    echo "   Open with: open coverage/html/index.html"
else
    echo ""
    echo "⚠️  lcov not found. Install with: brew install lcov (macOS) or apt-get install lcov (Ubuntu)"
    echo "   Coverage data available at: coverage/lcov.info"
fi

echo ""
echo "🎯 Running specific test categories..."

echo ""
echo "📋 Configuration Tests:"
flutter test test/liveness_check_config_test.dart

echo ""
echo "🎨 Widget Tests:"
flutter test test/liveness_check_screen_test.dart

echo ""
echo "🎭 Painter Tests:"
flutter test test/widget/dashed_circle_painter_test.dart

echo ""
echo "🔄 Integration Tests:"
flutter test test/integration_test.dart

echo ""
echo "🚨 Error Handling Tests:"
flutter test test/error_handling_test.dart

echo ""
echo "✅ All tests completed successfully!"
echo ""
echo "📝 Test Summary:"
echo "   • Configuration Tests: ✅"
echo "   • Widget Tests: ✅"
echo "   • Painter Tests: ✅"
echo "   • Integration Tests: ✅"
echo "   • Error Handling Tests: ✅"
echo ""
echo "🎉 Test suite execution complete!"

# Show coverage summary if available
if [ -f "coverage/lcov.info" ]; then
    echo ""
    echo "📊 Coverage Summary:"
    echo "==================="

    if command -v lcov &> /dev/null; then
        lcov --summary coverage/lcov.info
    else
        echo "Coverage data generated at: coverage/lcov.info"
    fi
fi