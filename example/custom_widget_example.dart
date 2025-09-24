import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

class CustomWidgetExample extends StatefulWidget {
  const CustomWidgetExample({super.key});

  @override
  State<CustomWidgetExample> createState() => _CustomWidgetExampleState();
}

class _CustomWidgetExampleState extends State<CustomWidgetExample> {
  LivenessStatus _currentStatus = LivenessStatus.init;
  int _attemptCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LivenessCheckScreen(
        config: LivenessCheckConfig(
          status: _currentStatus,
          placeholder: "Custom header and bottom widgets example",

          // Custom header widget
          customHeader: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Identity Verification',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Step 2 of 3 - Liveness Check',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Attempt ${_attemptCount + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Custom bottom widget (only shown when not in fail state with try again button)
          customBottomWidget: _currentStatus != LivenessStatus.fail
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Instructions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Position your face within the circle\n'
                        '2. Look directly at the camera\n'
                        '3. Blink your eyes 3 times when prompted\n'
                        '4. Keep your device steady during scanning',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: Colors.blue.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Your privacy is protected. Images are processed locally.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : null,

          theme: const LivenessCheckTheme(
            borderStyle: CircleBorderStyle.dashed,
            borderColor: Color(0xFF1976D2),
            borderWidth: 3,
            dashLength: 10,
            dashGap: 6,
            circleSize: 0.7,
            cameraPadding: 8,
            backgroundColor: Colors.white,
            fontFamily: 'Roboto',
          ),

          settings: const LivenessCheckSettings(
            requiredBlinkCount: 3,
            showProgress: true,
            showErrorMessage: true,
            showTryAgainButton: true,
            maxRetryAttempts: 4,
          ),

          showLoading: false, // Dynamic loading control

          messages: const LivenessCheckMessages(
            title: '',  // Empty since we have custom header
            tryAgainButtonText: 'Try Again',
            noFaceDetected: 'Please position your face in the circle',
            livenessCheckPassed: 'Verification successful!',
          ),

          callbacks: LivenessCheckCallbacks(
            onSuccess: () {
              setState(() {
                _currentStatus = LivenessStatus.success;
              });

              // Show success animation or navigate
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade600),
                          const SizedBox(width: 8),
                          const Text('Verification Complete'),
                        ],
                      ),
                      content: const Text(
                        'Your identity has been successfully verified. '
                        'You can now proceed to the next step.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Continue'),
                        ),
                      ],
                    ),
                  );
                }
              });
            },

            onError: (error) {
              setState(() {
                _currentStatus = LivenessStatus.fail;
              });
            },

            onTryAgain: () {
              setState(() {
                _currentStatus = LivenessStatus.init;
                _attemptCount++;
              });
            },

            onMaxRetryReached: (attemptCount) {
              showDialog(
                context: context,
                barrierDismissible: false,
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
                    'This might be due to poor lighting or camera quality. '
                    'Please try again later or contact support.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Close'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _currentStatus = LivenessStatus.init;
                          _attemptCount = 0;
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            },

            onProgressUpdate: (blinkCount, isSmiling) {
              print('Liveness progress: $blinkCount blinks, smiling: $isSmiling');
            },
          ),
        ),
      ),
    );
  }
}