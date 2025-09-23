import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/liveness_check_screen.dart';
import 'package:flutter_liveness_check/liveness_check_config.dart';

class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liveness Check Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _showDefaultExample(context),
              child: const Text('Default Configuration'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCustomThemeExample(context),
              child: const Text('Custom Theme Example'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCustomHeaderBottomExample(context),
              child: const Text('Custom Header & Bottom'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCallbackExample(context),
              child: const Text('With Callbacks'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDefaultExample(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LivenessCheckScreen(),
      ),
    );
  }

  void _showCustomThemeExample(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessCheckScreen(
          config: LivenessCheckConfig(
            theme: const LivenessCheckTheme(
              backgroundColor: Color(0xFF1E1E1E),
              primaryColor: Colors.purple,
              successColor: Colors.teal,
              errorColor: Colors.orange,
              textColor: Colors.white,
              overlayColor: Color(0xFF1E1E1E),
              circleSize: 0.8,
              borderWidth: 6,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              messageTextStyle: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            messages: const LivenessCheckMessages(
              title: 'Face Verification',
              noFaceDetected: 'Position your face within the circle',
              livenessCheckPassed: 'Verification successful!',
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomHeaderBottomExample(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessCheckScreen(
          config: LivenessCheckConfig(
            customHeader: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade900,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Identity Verification',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please follow the instructions to verify your identity',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            customBottomWidget: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey.shade100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tips:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Ensure good lighting',
                    style: TextStyle(fontSize: 14),
                  ),
                  const Text(
                    '• Hold your device steady',
                    style: TextStyle(fontSize: 14),
                  ),
                  const Text(
                    '• Look directly at the camera',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            theme: const LivenessCheckTheme(
              backgroundColor: Colors.white,
              primaryColor: Colors.blue,
              successColor: Colors.green,
              errorColor: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  void _showCallbackExample(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessCheckScreen(
          config: LivenessCheckConfig(
            settings: const LivenessCheckSettings(
              requiredBlinkCount: 2,
              requireSmile: true,
              showProgress: true,
              autoNavigateOnSuccess: false,
            ),
            callbacks: LivenessCheckCallbacks(
              onSuccess: () {
                print('Liveness check completed successfully!');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification successful!')),
                );
              },
              onError: (error) {
                print('Error: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              },
              onCancel: () {
                print('User cancelled liveness check');
              },
              onPhotoTaken: (imagePath) {
                print('Photo captured at: $imagePath');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Photo saved: $imagePath')),
                );
                Navigator.pop(context);
              },
              onProgressUpdate: (blinkCount, isSmiling) {
                print('Progress: $blinkCount blinks, smiling: $isSmiling');
              },
            ),
            messages: const LivenessCheckMessages(
              title: 'Custom Verification',
              livenessCheckPassed: 'Perfect! Photo captured.',
            ),
          ),
        ),
      ),
    );
  }
}

class MinimalExample extends StatelessWidget {
  const MinimalExample({super.key});

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      config: LivenessCheckConfig(
        theme: const LivenessCheckTheme(
          primaryColor: Colors.indigo,
          successColor: Colors.green,
          errorColor: Colors.red,
        ),
        callbacks: LivenessCheckCallbacks(
          onPhotoTaken: (imagePath) {
            // Handle the captured photo
            print('Photo path: $imagePath');
            Navigator.pop(context);
          },
          onError: (error) {
            // Handle errors
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          },
        ),
      ),
    );
  }
}

class BankingAppExample extends StatelessWidget {
  const BankingAppExample({super.key});

  @override
  Widget build(BuildContext context) {
    return LivenessCheckScreen(
      config: LivenessCheckConfig(
        theme: const LivenessCheckTheme(
          backgroundColor: Color(0xFFF8F9FA),
          primaryColor: Color(0xFF1565C0),
          successColor: Color(0xFF2E7D32),
          errorColor: Color(0xFFD32F2F),
          textColor: Color(0xFF1A1A1A),
          circleSize: 0.75,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        messages: const LivenessCheckMessages(
          title: 'Identity Verification',
          noFaceDetected: 'Please position your face in the verification area',
          livenessCheckPassed: 'Identity verified successfully!',
          multipleFacesDetected: 'Multiple faces detected. Please ensure only you are in the frame.',
        ),
        customHeader: Container(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
          decoration: const BoxDecoration(
            color: Color(0xFF1565C0),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Secure Banking',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.security, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Identity Verification Required',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Please complete face verification to continue',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        settings: const LivenessCheckSettings(
          requiredBlinkCount: 3,
          requireSmile: false,
          showProgress: false,
          autoNavigateOnSuccess: false,
        ),
        callbacks: LivenessCheckCallbacks(
          onSuccess: () {
            _showSuccessDialog(context);
          },
          onError: (error) {
            _showErrorDialog(context, error);
          },
          onPhotoTaken: (imagePath) {
            // Process the photo for banking verification
            print('Banking verification photo: $imagePath');
          },
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 64),
            SizedBox(height: 16),
            Text(
              'Verification Successful',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your identity has been verified. You can now proceed with your banking transaction.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Failed'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}