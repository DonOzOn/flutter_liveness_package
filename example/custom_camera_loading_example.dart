import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

/// Example demonstrating custom camera loading widget.
///
/// Shows how to replace the default camera initialization loading view
/// with a custom widget.
class CustomCameraLoadingExample extends StatefulWidget {
  const CustomCameraLoadingExample({super.key});

  @override
  State<CustomCameraLoadingExample> createState() =>
      _CustomCameraLoadingExampleState();
}

class _CustomCameraLoadingExampleState
    extends State<CustomCameraLoadingExample> {
  LivenessStatus _status = LivenessStatus.init;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Camera Loading'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: LivenessCheckScreen(
        config: LivenessCheckConfig(
          status: _status,

          // Custom camera initialization loading widget
          customCameraLoadingWidget: Container(
            color: Colors.teal.shade50,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 24),

                  // Loading indicator
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Setting Up Camera',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Please wait while we initialize your camera...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          callbacks: LivenessCheckCallbacks(
            onSuccess: () => setState(() => _status = LivenessStatus.success),
            onError: (error) => setState(() => _status = LivenessStatus.fail),
            onTryAgain: () => setState(() => _status = LivenessStatus.init),
          ),

          theme: const LivenessCheckTheme(
            primaryColor: Colors.teal,
            borderStyle: CircleBorderStyle.solid,
          ),
        ),
      ),
    );
  }
}

/// Minimal example with simple custom loading
class MinimalCameraLoadingExample extends StatefulWidget {
  const MinimalCameraLoadingExample({super.key});

  @override
  State<MinimalCameraLoadingExample> createState() =>
      _MinimalCameraLoadingExampleState();
}

class _MinimalCameraLoadingExampleState
    extends State<MinimalCameraLoadingExample> {
  LivenessStatus _status = LivenessStatus.init;

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      config: LivenessCheckConfig(
        status: _status,

        // Simple text-based loading
        customCameraLoadingWidget: const Center(
          child: Text(
            '📷 Initializing camera...',
            style: TextStyle(fontSize: 20),
          ),
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

/// Advanced example with branded loading screen
class BrandedCameraLoadingExample extends StatefulWidget {
  const BrandedCameraLoadingExample({super.key});

  @override
  State<BrandedCameraLoadingExample> createState() =>
      _BrandedCameraLoadingExampleState();
}

class _BrandedCameraLoadingExampleState
    extends State<BrandedCameraLoadingExample> {
  LivenessStatus _status = LivenessStatus.init;

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      config: LivenessCheckConfig(
        status: _status,

        // Branded loading screen
        customCameraLoadingWidget: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.purple.shade600,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    size: 60,
                    color: Colors.purple,
                  ),
                ),

                const SizedBox(height: 40),

                // Loading indicator
                const CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),

                const SizedBox(height: 24),

                // Company name
                const Text(
                  'SecureVerify',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                // Status text
                const Text(
                  'Preparing verification camera',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const Spacer(),

                // Security badge
                Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Bank-grade security',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
