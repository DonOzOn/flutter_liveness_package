// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

class FigmaStyleExample extends StatefulWidget {
  const FigmaStyleExample({super.key});

  @override
  State<FigmaStyleExample> createState() => _FigmaStyleExampleState();
}

class _FigmaStyleExampleState extends State<FigmaStyleExample> {
  LivenessStatus _currentStatus = LivenessStatus.init;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Figma Style - Dashed Circle'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: LivenessCheckScreen(
        config: LivenessCheckConfig(
          status: _currentStatus,
          placeholder:
              "Vui lòng điều chỉnh khuôn mặt cho đến khi vòng tròn chuyển xanh",
          theme: const LivenessCheckTheme(
            // Figma-inspired styling
            borderStyle: CircleBorderStyle.dashed,
            borderColor: Color(0xFF35C659), // Green color from Figma
            borderWidth: 4,
            dashLength: 8,
            dashGap: 8,
            cameraPadding: 10, // Space between border and camera
            circleSize: 0.65,
            backgroundColor: Colors.white,
            overlayColor: Colors.white,
            // Custom font
            fontFamily: 'Inter',
          ),
          settings: const LivenessCheckSettings(
            requiredBlinkCount: 3,
            showProgress: true,
            showErrorMessage: true,
            showTryAgainButton: true,
            maxRetryAttempts: 3,
          ),
          messages: const LivenessCheckMessages(
            title: 'Xác thực khuôn mặt',
            tryAgainButtonText: 'Thử lại',
            noFaceDetected:
                'Không phát hiện khuôn mặt. Vui lòng đưa mặt vào vòng tròn.',
            multipleFacesDetected:
                'Phát hiện nhiều khuôn mặt. Chỉ cho phép một người.',
            moveCloserToCamera:
                'Di chuyển gần camera hơn hoặc giữ thiết bị ổn định.',
            holdStill: 'Giữ yên. Đặc điểm khuôn mặt không rõ ràng.',
            imageTooBlurry: 'Hình ảnh quá mờ. Giữ thiết bị ổn định.',
            poorLighting: 'Điều kiện ánh sáng kém.',
            livenessCheckPassed: 'Xác thực thành công! Đang chụp ảnh...',
          ),
          callbacks: LivenessCheckCallbacks(
            onSuccess: () {
              setState(() {
                _currentStatus = LivenessStatus.success;
              });
              // Auto navigate back after 2 seconds
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.of(context).pop(true);
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
              });
            },
            onMaxRetryReached: (attemptCount) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Quá nhiều lần thử'),
                  content: Text(
                    'Bạn đã thử $attemptCount lần. Vui lòng thử lại sau.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              );
            },
            onCancel: () {
              Navigator.of(context).pop(false);
            },
          ),
        ),
      ),
    );
  }
}
