import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

/// Example demonstrating custom try again button styling.
///
/// Shows how to customize button height, padding, border radius,
/// and colors for the try again button.
class CustomButtonExample extends StatefulWidget {
  const CustomButtonExample({super.key});

  @override
  State<CustomButtonExample> createState() => _CustomButtonExampleState();
}

class _CustomButtonExampleState extends State<CustomButtonExample> {
  LivenessStatus _status = LivenessStatus.fail; // Start with fail to show button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Button Styling'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: LivenessCheckScreen(
        config: LivenessCheckConfig(
          status: _status,

          theme: LivenessCheckTheme(
            primaryColor: Colors.deepOrange,
            borderStyle: CircleBorderStyle.solid,

            // Try Again Button Customization
            btnRetryBGColor: Colors.deepOrange,
            btnTextRetryColor: Colors.white,
            btnRetryHeight: 56, // Custom height (default: 44)
            btnRetryPadding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            btnRetryBorderRadius: 28, // Fully rounded button
          ),

          messages: const LivenessCheckMessages(
            tryAgainButtonText: 'Retry Verification',
          ),

          callbacks: LivenessCheckCallbacks(
            onSuccess: () => setState(() => _status = LivenessStatus.success),
            onError: (error) => setState(() => _status = LivenessStatus.fail),
            onTryAgain: () => setState(() => _status = LivenessStatus.init),
          ),
        ),
      ),
    );
  }
}

/// Example with minimal flat button
class FlatButtonExample extends StatefulWidget {
  const FlatButtonExample({super.key});

  @override
  State<FlatButtonExample> createState() => _FlatButtonExampleState();
}

class _FlatButtonExampleState extends State<FlatButtonExample> {
  LivenessStatus _status = LivenessStatus.fail;

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      config: LivenessCheckConfig(
        status: _status,

        theme: const LivenessCheckTheme(
          primaryColor: Colors.indigo,

          // Flat, minimal button
          btnRetryBGColor: Colors.transparent,
          btnTextRetryColor: Colors.indigo,
          btnRetryHeight: 40,
          btnRetryPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          btnRetryBorderRadius: 4,
        ),

        messages: const LivenessCheckMessages(
          tryAgainButtonText: 'Try Again',
        ),

        callbacks: LivenessCheckCallbacks(
          onTryAgain: () => setState(() => _status = LivenessStatus.init),
        ),
      ),
    );
  }
}

/// Example with large elevated button
class LargeButtonExample extends StatefulWidget {
  const LargeButtonExample({super.key});

  @override
  State<LargeButtonExample> createState() => _LargeButtonExampleState();
}

class _LargeButtonExampleState extends State<LargeButtonExample> {
  LivenessStatus _status = LivenessStatus.fail;

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      config: LivenessCheckConfig(
        status: _status,

        theme: const LivenessCheckTheme(
          primaryColor: Colors.purple,

          // Large, prominent button
          btnRetryBGColor: Colors.purple,
          btnTextRetryColor: Colors.white,
          btnRetryHeight: 64, // Tall button
          btnRetryPadding: EdgeInsets.symmetric(horizontal: 48, vertical: 20),
          btnRetryBorderRadius: 16, // Rounded corners
        ),

        messages: const LivenessCheckMessages(
          tryAgainButtonText: '🔄 Try Again',
        ),

        callbacks: LivenessCheckCallbacks(
          onTryAgain: () => setState(() => _status = LivenessStatus.init),
        ),
      ),
    );
  }
}

/// Example with gradient button (using custom widget approach)
class GradientButtonExample extends StatefulWidget {
  const GradientButtonExample({super.key});

  @override
  State<GradientButtonExample> createState() => _GradientButtonExampleState();
}

class _GradientButtonExampleState extends State<GradientButtonExample> {
  LivenessStatus _status = LivenessStatus.fail;

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      config: LivenessCheckConfig(
        status: _status,

        // Hide default button and use custom widget
        settings: const LivenessCheckSettings(
          showTryAgainButton: false,
        ),

        // Custom gradient button
        customBottomWidget: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => setState(() => _status = LivenessStatus.init),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        callbacks: LivenessCheckCallbacks(
          onSuccess: () => setState(() => _status = LivenessStatus.success),
          onError: (error) => setState(() => _status = LivenessStatus.fail),
        ),
      ),
    );
  }
}

/// Example with outlined button
class OutlinedButtonExample extends StatefulWidget {
  const OutlinedButtonExample({super.key});

  @override
  State<OutlinedButtonExample> createState() => _OutlinedButtonExampleState();
}

class _OutlinedButtonExampleState extends State<OutlinedButtonExample> {
  LivenessStatus _status = LivenessStatus.fail;

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      config: LivenessCheckConfig(
        status: _status,

        theme: LivenessCheckTheme(
          primaryColor: Colors.teal,
          backgroundColor: Colors.grey.shade50,

          // Outlined style button
          btnRetryBGColor: Colors.transparent,
          btnTextRetryColor: Colors.teal,
          btnRetryHeight: 48,
          btnRetryPadding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 12,
          ),
          btnRetryBorderRadius: 24,
        ),

        callbacks: LivenessCheckCallbacks(
          onTryAgain: () => setState(() => _status = LivenessStatus.init),
        ),
      ),
    );
  }
}
