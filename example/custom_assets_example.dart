import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

class CustomAssetsExample extends StatefulWidget {
  const CustomAssetsExample({super.key});

  @override
  State<CustomAssetsExample> createState() => _CustomAssetsExampleState();
}

class _CustomAssetsExampleState extends State<CustomAssetsExample> {
  LivenessStatus _currentStatus = LivenessStatus.init;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Assets Example')),
      body: Column(
        children: [
          // Control buttons for testing different states
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStatus = LivenessStatus.init;
                    });
                  },
                  child: const Text('Init'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStatus = LivenessStatus.success;
                    });
                  },
                  child: const Text('Success'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStatus = LivenessStatus.fail;
                    });
                  },
                  child: const Text('Fail'),
                ),
              ],
            ),
          ),
          Expanded(
            child: LivenessCheckScreen(
              config: LivenessCheckConfig(
                status: _currentStatus,
                placeholder: "Face detection with custom success/fail assets",
                theme: const LivenessCheckTheme(
                  borderStyle: CircleBorderStyle.solid,
                  borderColor: Colors.purple,
                  borderWidth: 3,
                  circleSize: 0.6,
                  cameraPadding: 5,
                  // Custom assets - replace with your own asset paths
                  successAsset:
                      'packages/flutter_liveness_check/assets/success.png',
                  failAsset: 'packages/flutter_liveness_check/assets/fail.png',
                  // Custom styling
                  successColor: Colors.green,
                  errorColor: Colors.red,
                  fontFamily: 'Arial',
                ),
                settings: const LivenessCheckSettings(
                  requiredBlinkCount: 2,
                  showProgress: true,
                  showErrorMessage: true,
                  showTryAgainButton: true,
                  maxRetryAttempts: 5,
                ),
                showLoading: false, // Dynamic loading control
                messages: const LivenessCheckMessages(
                  title: 'Custom Liveness Check',
                  tryAgainButtonText: 'Retry Detection',
                  noFaceDetected: 'Please show your face to the camera',
                  multipleFacesDetected: 'Only one person should be visible',
                  livenessCheckPassed: 'Perfect! Verification completed.',
                ),
                callbacks: LivenessCheckCallbacks(
                  onSuccess: () {
                    setState(() {
                      _currentStatus = LivenessStatus.success;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Liveness verification successful!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  onError: (error) {
                    setState(() {
                      _currentStatus = LivenessStatus.fail;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Verification failed: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  onTryAgain: () {
                    setState(() {
                      _currentStatus = LivenessStatus.init;
                    });
                    debugPrint('User clicked retry - resetting to init state');
                  },
                  onMaxRetryReached: (attemptCount) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Maximum Attempts Reached'),
                        content: Text(
                          'You have reached the maximum number of attempts ($attemptCount). '
                          'Please try again later or contact support.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  onPhotoTaken: (imagePath) {
                    debugPrint('Photo captured at: $imagePath');
                  },
                  onProgressUpdate: (blinkCount, isSmiling) {
                    debugPrint(
                      'Progress: Blinks=$blinkCount, Smiling=$isSmiling',
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
