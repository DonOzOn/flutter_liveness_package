import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

class CustomLoadingExample extends StatefulWidget {
  const CustomLoadingExample({super.key});

  @override
  State<CustomLoadingExample> createState() => _CustomLoadingExampleState();
}

class _CustomLoadingExampleState extends State<CustomLoadingExample> {
  LivenessStatus _currentStatus = LivenessStatus.init;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Loading Example'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Control buttons for testing
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentStatus = LivenessStatus.init;
                          _isProcessing = false;
                        });
                      },
                      child: const Text('Init'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isProcessing = !_isProcessing;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isProcessing ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isProcessing ? 'Hide Loading' : 'Show Loading'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentStatus = LivenessStatus.success;
                          _isProcessing = false;
                        });
                      },
                      child: const Text('Success'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentStatus = LivenessStatus.fail;
                          _isProcessing = false;
                        });
                      },
                      child: const Text('Fail'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: LivenessCheckScreen(
              config: LivenessCheckConfig(
                status: _currentStatus,
                showLoading: _isProcessing,
                placeholder: "Custom loading widget demonstration",

                // Custom loading widget with animation and branding
                customLoadingWidget: _buildCustomLoadingWidget(),

                theme: const LivenessCheckTheme(
                  borderStyle: CircleBorderStyle.dashed,
                  borderColor: Colors.deepPurple,
                  borderWidth: 4,
                  dashLength: 12,
                  dashGap: 8,
                  circleSize: 0.65,
                  cameraPadding: 15,
                  primaryColor: Colors.deepPurple,
                  fontFamily: 'Roboto',
                ),

                settings: const LivenessCheckSettings(
                  requiredBlinkCount: 3,
                  showProgress: true,
                  showErrorMessage: true,
                  showTryAgainButton: true,
                  maxRetryAttempts: 3,
                ),

                messages: const LivenessCheckMessages(
                  title: 'Identity Verification',
                  tryAgainButtonText: 'Try Again',
                  noFaceDetected: 'Please position your face in the circle',
                  livenessCheckPassed: 'Verification completed successfully!',
                ),

                callbacks: LivenessCheckCallbacks(
                  onSuccess: () {
                    // Simulate processing with custom loading
                    setState(() {
                      _isProcessing = true;
                    });

                    // Simulate server processing time
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        setState(() {
                          _currentStatus = LivenessStatus.success;
                          _isProcessing = false;
                        });
                      }
                    });
                  },

                  onError: (error) {
                    setState(() {
                      _currentStatus = LivenessStatus.fail;
                      _isProcessing = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verification failed: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },

                  onTryAgain: () {
                    setState(() {
                      _currentStatus = LivenessStatus.init;
                      _isProcessing = false;
                    });
                  },

                  onMaxRetryReached: (attemptCount) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade600),
                            const SizedBox(width: 8),
                            const Text('Verification Failed'),
                          ],
                        ),
                        content: Text(
                          'Unable to verify your identity after $attemptCount attempts. '
                          'Please ensure good lighting and stable device position.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
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

  Widget _buildCustomLoadingWidget() {
    return Container(
      color: Colors.deepPurple.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated loading indicator with gradient
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Loading text with animation
            const Text(
              'Processing Verification',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Analyzing biometric data...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            // Progress steps
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStepIndicator('Capture', true),
                _buildStepConnector(),
                _buildStepIndicator('Analyze', true),
                _buildStepConnector(),
                _buildStepIndicator('Verify', false),
              ],
            ),

            const SizedBox(height: 16),

            // Security notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Secure processing',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: isActive
              ? Icon(
                  Icons.check,
                  color: Colors.deepPurple,
                  size: 14,
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}