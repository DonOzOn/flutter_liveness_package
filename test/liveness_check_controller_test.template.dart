import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

/// Template for LivenessCheckController tests
/// This is the HIGHEST PRIORITY test file to implement
///
/// Copy this file to: test/liveness_check_controller_test.dart
/// Remove .template from the filename and implement the tests below

void main() {
  group('LivenessCheckController Tests', () {
    late LivenessCheckController controller;

    setUp(() {
      controller = LivenessCheckController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('Initialization and Initial State', () {
      test('should initialize with correct default values', () {
        expect(controller.isInitialized, false);
        expect(controller.isPaused, false);
      });

      test('should be a ChangeNotifier', () {
        expect(controller, isA<ChangeNotifier>());
      });
    });

    group('State Management', () {
      test('setInitialized should update isInitialized state', () {
        expect(controller.isInitialized, false);

        controller.setInitialized(true);

        expect(controller.isInitialized, true);
      });

      test('setInitialized should notify listeners when value changes', () {
        int listenerCallCount = 0;
        controller.addListener(() {
          listenerCallCount++;
        });

        controller.setInitialized(true);

        expect(listenerCallCount, 1);
      });

      test('setInitialized should not notify listeners when value unchanged', () {
        controller.setInitialized(false); // Already false

        int listenerCallCount = 0;
        controller.addListener(() {
          listenerCallCount++;
        });

        controller.setInitialized(false); // Still false

        expect(listenerCallCount, 0);
      });

      test('setPaused should update isPaused state', () {
        expect(controller.isPaused, false);

        controller.setPaused(true);

        expect(controller.isPaused, true);
      });

      test('setPaused should notify listeners when value changes', () {
        int listenerCallCount = 0;
        controller.addListener(() {
          listenerCallCount++;
        });

        controller.setPaused(true);

        expect(listenerCallCount, 1);
      });

      test('setPaused should not notify listeners when value unchanged', () {
        controller.setPaused(false);

        int listenerCallCount = 0;
        controller.addListener(() {
          listenerCallCount++;
        });

        controller.setPaused(false);

        expect(listenerCallCount, 0);
      });
    });

    group('Callback Registration', () {
      test('should register initialize callback', () {
        bool callbackCalled = false;

        controller.registerInitializeCallback(() {
          callbackCalled = true;
        });

        controller.initializeCamera();

        expect(callbackCalled, true);
      });

      test('should register dispose callback', () {
        bool callbackCalled = false;

        controller.registerDisposeCallback(() {
          callbackCalled = true;
        });

        controller.disposeCamera();

        expect(callbackCalled, true);
      });

      test('should register reset callback', () {
        bool callbackCalled = false;

        controller.registerResetCallback(() {
          callbackCalled = true;
        });

        controller.resetState();

        expect(callbackCalled, true);
      });

      test('should register pause callback', () async {
        bool callbackCalled = false;

        controller.registerPauseCallback(() async {
          callbackCalled = true;
        });

        await controller.pauseDetection();

        expect(callbackCalled, true);
      });

      test('should register resume callback', () async {
        bool callbackCalled = false;

        controller.registerResumeCallback(() async {
          callbackCalled = true;
        });

        await controller.resumeDetection();

        expect(callbackCalled, true);
      });

      test('should allow callback override', () {
        int callCount = 0;

        controller.registerInitializeCallback(() {
          callCount++;
        });

        controller.registerInitializeCallback(() {
          callCount += 10;
        });

        controller.initializeCamera();

        // Second callback should override the first
        expect(callCount, 10);
      });
    });

    group('Camera Lifecycle Operations', () {
      test('initializeCamera without registered callback should not throw', () {
        // No callback registered
        expect(() => controller.initializeCamera(), returnsNormally);
      });

      test('disposeCamera without registered callback should not throw', () {
        // No callback registered
        expect(() => controller.disposeCamera(), returnsNormally);
      });

      test('resetState without registered callback should not throw', () {
        // No callback registered
        expect(() => controller.resetState(), returnsNormally);
      });

      test('pauseDetection without registered callback should not throw', () async {
        // No callback registered
        await expectLater(controller.pauseDetection(), completes);
      });

      test('resumeDetection without registered callback should not throw', () async {
        // No callback registered
        await expectLater(controller.resumeDetection(), completes);
      });

      test('should handle async pause callback', () async {
        bool started = false;
        bool completed = false;

        controller.registerPauseCallback(() async {
          started = true;
          await Future.delayed(const Duration(milliseconds: 10));
          completed = true;
        });

        expect(started, false);
        expect(completed, false);

        await controller.pauseDetection();

        expect(started, true);
        expect(completed, true);
      });

      test('should handle async resume callback', () async {
        bool started = false;
        bool completed = false;

        controller.registerResumeCallback(() async {
          started = true;
          await Future.delayed(const Duration(milliseconds: 10));
          completed = true;
        });

        expect(started, false);
        expect(completed, false);

        await controller.resumeDetection();

        expect(started, true);
        expect(completed, true);
      });
    });

    group('Pause and Resume Flow', () {
      test('should handle pause-resume cycle', () async {
        final List<String> actions = [];

        controller.registerPauseCallback(() async {
          actions.add('paused');
          controller.setPaused(true);
        });

        controller.registerResumeCallback(() async {
          actions.add('resumed');
          controller.setPaused(false);
        });

        expect(controller.isPaused, false);

        await controller.pauseDetection();
        expect(controller.isPaused, true);
        expect(actions, ['paused']);

        await controller.resumeDetection();
        expect(controller.isPaused, false);
        expect(actions, ['paused', 'resumed']);
      });

      test('should handle multiple pause calls', () async {
        int pauseCount = 0;

        controller.registerPauseCallback(() async {
          pauseCount++;
        });

        await controller.pauseDetection();
        await controller.pauseDetection();
        await controller.pauseDetection();

        expect(pauseCount, 3);
      });

      test('should handle multiple resume calls', () async {
        int resumeCount = 0;

        controller.registerResumeCallback(() async {
          resumeCount++;
        });

        await controller.resumeDetection();
        await controller.resumeDetection();
        await controller.resumeDetection();

        expect(resumeCount, 3);
      });
    });

    group('State Change Notifications', () {
      test('should notify listeners on initialization state change', () {
        final List<bool> states = [];

        controller.addListener(() {
          states.add(controller.isInitialized);
        });

        controller.setInitialized(true);
        controller.setInitialized(false);
        controller.setInitialized(true);

        expect(states, [true, false, true]);
      });

      test('should notify listeners on pause state change', () {
        final List<bool> states = [];

        controller.addListener(() {
          states.add(controller.isPaused);
        });

        controller.setPaused(true);
        controller.setPaused(false);
        controller.setPaused(true);

        expect(states, [true, false, true]);
      });

      test('should support multiple listeners', () {
        int listener1Calls = 0;
        int listener2Calls = 0;

        controller.addListener(() {
          listener1Calls++;
        });

        controller.addListener(() {
          listener2Calls++;
        });

        controller.setInitialized(true);

        expect(listener1Calls, 1);
        expect(listener2Calls, 1);
      });

      test('should stop notifying after listener removed', () {
        int listenerCalls = 0;

        void listener() {
          listenerCalls++;
        }

        controller.addListener(listener);
        controller.setInitialized(true);
        expect(listenerCalls, 1);

        controller.removeListener(listener);
        controller.setInitialized(false);
        expect(listenerCalls, 1); // Should still be 1
      });
    });

    group('Complete Lifecycle Simulation', () {
      test('should handle full camera lifecycle', () async {
        final List<String> lifecycle = [];

        // Register all callbacks
        controller.registerInitializeCallback(() {
          lifecycle.add('initialized');
          controller.setInitialized(true);
        });

        controller.registerPauseCallback(() async {
          lifecycle.add('paused');
          controller.setPaused(true);
        });

        controller.registerResumeCallback(() async {
          lifecycle.add('resumed');
          controller.setPaused(false);
        });

        controller.registerResetCallback(() {
          lifecycle.add('reset');
        });

        controller.registerDisposeCallback(() {
          lifecycle.add('disposed');
          controller.setInitialized(false);
        });

        // Simulate full lifecycle
        controller.initializeCamera();
        expect(controller.isInitialized, true);

        await controller.pauseDetection();
        expect(controller.isPaused, true);

        await controller.resumeDetection();
        expect(controller.isPaused, false);

        controller.resetState();

        controller.disposeCamera();
        expect(controller.isInitialized, false);

        expect(lifecycle, [
          'initialized',
          'paused',
          'resumed',
          'reset',
          'disposed',
        ]);
      });
    });

    group('Edge Cases', () {
      test('should handle rapid state changes', () {
        controller.setInitialized(true);
        controller.setInitialized(false);
        controller.setInitialized(true);
        controller.setInitialized(false);

        expect(controller.isInitialized, false);
      });

      test('should handle initialization while already initialized', () {
        int callCount = 0;

        controller.registerInitializeCallback(() {
          callCount++;
          controller.setInitialized(true);
        });

        controller.initializeCamera();
        expect(callCount, 1);
        expect(controller.isInitialized, true);

        // Try to initialize again
        controller.initializeCamera();
        expect(callCount, 2); // Callback called again
      });

      test('should handle dispose while not initialized', () {
        bool disposeCalled = false;

        controller.registerDisposeCallback(() {
          disposeCalled = true;
        });

        expect(controller.isInitialized, false);
        controller.disposeCamera();

        expect(disposeCalled, true);
      });

      test('should handle pause when not initialized', () async {
        bool pauseCalled = false;

        controller.registerPauseCallback(() async {
          pauseCalled = true;
        });

        expect(controller.isInitialized, false);
        await controller.pauseDetection();

        expect(pauseCalled, true);
      });

      test('should handle resume when not paused', () async {
        bool resumeCalled = false;

        controller.registerResumeCallback(() async {
          resumeCalled = true;
        });

        expect(controller.isPaused, false);
        await controller.resumeDetection();

        expect(resumeCalled, true);
      });
    });

    group('Disposal and Cleanup', () {
      test('should clear all callbacks on dispose', () {
        bool initCalled = false;
        bool disposeCalled = false;
        bool resetCalled = false;

        controller.registerInitializeCallback(() => initCalled = true);
        controller.registerDisposeCallback(() => disposeCalled = true);
        controller.registerResetCallback(() => resetCalled = true);

        controller.dispose();

        // After dispose, callbacks should not be called
        controller.initializeCamera();
        controller.disposeCamera();
        controller.resetState();

        expect(initCalled, false);
        expect(disposeCalled, false);
        expect(resetCalled, false);
      });

      test('should handle multiple dispose calls', () {
        expect(() {
          controller.dispose();
          controller.dispose();
          controller.dispose();
        }, returnsNormally);
      });

      test('should not notify listeners after dispose', () {
        int listenerCalls = 0;

        controller.addListener(() {
          listenerCalls++;
        });

        controller.dispose();

        // This should not notify listeners
        controller.setInitialized(true);

        expect(listenerCalls, 0);
      });
    });

    group('Memory Leak Prevention', () {
      test('should not leak when listener added and removed', () {
        final List<LivenessCheckController> controllers = [];

        for (int i = 0; i < 100; i++) {
          final c = LivenessCheckController();
          void listener() {}
          c.addListener(listener);
          c.removeListener(listener);
          controllers.add(c);
        }

        // Dispose all
        for (final c in controllers) {
          c.dispose();
        }

        expect(controllers.length, 100);
      });
    });
  });
}
