import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

class BasicLivenessExample extends StatefulWidget {
  const BasicLivenessExample({super.key});

  @override
  State<BasicLivenessExample> createState() => _BasicLivenessExampleState();
}

class _BasicLivenessExampleState extends State<BasicLivenessExample> {
  LivenessStatus _currentStatus = LivenessStatus.init;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Liveness Check'),
      ),
      body: LivenessCheckScreen(
        config: LivenessCheckConfig(
          status: _currentStatus,
          placeholder: "Please position your face in the circle and blink 3 times",
          theme: const LivenessCheckTheme(
            borderStyle: CircleBorderStyle.solid,
            borderColor: Colors.blue,
            borderWidth: 4,
            circleSize: 0.65,
          ),
          settings: const LivenessCheckSettings(
            requiredBlinkCount: 3,
            showProgress: true,
            showErrorMessage: true,
          ),
          callbacks: LivenessCheckCallbacks(
            onSuccess: () {
              setState(() {
                _currentStatus = LivenessStatus.success;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Liveness check passed!')),
              );
            },
            onError: (error) {
              setState(() {
                _currentStatus = LivenessStatus.fail;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $error')),
              );
            },
            onTryAgain: () {
              setState(() {
                _currentStatus = LivenessStatus.init;
              });
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}