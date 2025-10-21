import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

/// Example demonstrating manual camera control using LivenessCheckController.
///
/// This example shows how to:
/// - Create and use a controller
/// - Manually initialize and dispose the camera
/// - Reset the liveness state
/// - Listen to initialization status changes
class ControllerExample extends StatefulWidget {
  const ControllerExample({super.key});

  @override
  State<ControllerExample> createState() => _ControllerExampleState();
}

class _ControllerExampleState extends State<ControllerExample> {
  final LivenessCheckController _controller = LivenessCheckController();
  LivenessStatus _status = LivenessStatus.init;

  @override
  void initState() {
    super.initState();
    // Listen to controller state changes
    _controller.addListener(() {
      debugPrint('Camera initialized: ${_controller.isInitialized}');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controller Example'),
        actions: [
          // Manual camera controls
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Initialize Camera',
            onPressed: () async {
              await _controller.initializeCamera();
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_off),
            tooltip: 'Dispose Camera',
            onPressed: () async {
              await _controller.disposeCamera();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset State',
            onPressed: () {
              _controller.resetState();
            },
          ),
        ],
      ),
      body: LivenessCheckScreen(
        controller: _controller,
        config: LivenessCheckConfig(
          status: _status,
          appBarConfig: const AppBarConfig(
            title: 'Manual Camera Control',
            showBackButton: true,
          ),
          callbacks: LivenessCheckCallbacks(
            onSuccess: () {
              setState(() => _status = LivenessStatus.success);
              debugPrint('✓ Liveness check passed!');
            },
            onError: (error) {
              setState(() => _status = LivenessStatus.fail);
              debugPrint('✗ Error: $error');
            },
            onTryAgain: () {
              setState(() => _status = LivenessStatus.init);
            },
            onPhotoTaken: (imagePath) {
              debugPrint('Photo saved: $imagePath');
            },
          ),
          theme: const LivenessCheckTheme(
            primaryColor: Colors.purple,
            borderStyle: CircleBorderStyle.solid,
          ),
        ),
      ),
    );
  }
}

/// Advanced example with lifecycle management
class AdvancedControllerExample extends StatefulWidget {
  const AdvancedControllerExample({super.key});

  @override
  State<AdvancedControllerExample> createState() =>
      _AdvancedControllerExampleState();
}

class _AdvancedControllerExampleState extends State<AdvancedControllerExample>
    with WidgetsBindingObserver {
  final LivenessCheckController _controller = LivenessCheckController();
  LivenessStatus _status = LivenessStatus.init;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle to manage camera resources
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Dispose camera when app goes to background
        _controller.disposeCamera();
        break;
      case AppLifecycleState.resumed:
        // Reinitialize camera when app comes back to foreground
        _controller.initializeCamera();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      controller: _controller,
      config: LivenessCheckConfig(
        status: _status,
        appBarConfig: const AppBarConfig(
          title: 'Advanced Lifecycle Example',
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
