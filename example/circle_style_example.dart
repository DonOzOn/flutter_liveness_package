import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

class CircleStyleExampleScreen extends StatelessWidget {
  const CircleStyleExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Style Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Example 1: Dashed border circle like the Figma design
            ElevatedButton(
              onPressed: () => _startLivenessCheck(
                context,
                title: 'Dashed Circle - Figma Style',
                config: LivenessCheckConfig(
                  theme: const LivenessCheckTheme(
                    borderStyle: CircleBorderStyle.dashed,
                    borderColor: Color(0xFF35C659), // Green color from Figma
                    borderWidth: 4,
                    dashLength: 8,
                    dashGap: 8,
                    cameraPadding: 10,
                    circleSize: 0.65,
                  ),
                  placeholder: "Vui lòng điều chỉnh khuôn mặt cho đến khi vòng tròn chuyển xanh",
                ),
              ),
              child: const Text('Dashed Circle - Figma Style'),
            ),
            const SizedBox(height: 16),

            // Example 2: Solid border circle with padding
            ElevatedButton(
              onPressed: () => _startLivenessCheck(
                context,
                title: 'Solid Circle with Padding',
                config: LivenessCheckConfig(
                  theme: const LivenessCheckTheme(
                    borderStyle: CircleBorderStyle.solid,
                    borderColor: Colors.blue,
                    borderWidth: 3,
                    cameraPadding: 20,
                    circleSize: 0.7,
                  ),
                ),
              ),
              child: const Text('Solid Circle with Padding'),
            ),
            const SizedBox(height: 16),

            // Example 3: Dashed border with custom dash pattern
            ElevatedButton(
              onPressed: () => _startLivenessCheck(
                context,
                title: 'Custom Dashed Pattern',
                config: LivenessCheckConfig(
                  theme: const LivenessCheckTheme(
                    borderStyle: CircleBorderStyle.dashed,
                    borderColor: Colors.purple,
                    borderWidth: 5,
                    dashLength: 12,
                    dashGap: 4,
                    cameraPadding: 15,
                    circleSize: 0.6,
                  ),
                ),
              ),
              child: const Text('Custom Dashed Pattern'),
            ),
            const SizedBox(height: 16),

            // Example 4: No padding (original style)
            ElevatedButton(
              onPressed: () => _startLivenessCheck(
                context,
                title: 'Original Style (No Padding)',
                config: const LivenessCheckConfig(
                  theme: LivenessCheckTheme(
                    borderStyle: CircleBorderStyle.solid,
                    borderColor: Colors.blue,
                    borderWidth: 4,
                    cameraPadding: 0, // No padding
                    circleSize: 0.65,
                  ),
                ),
              ),
              child: const Text('Original Style (No Padding)'),
            ),
            const SizedBox(height: 16),

            // Example 5: Hide error messages
            ElevatedButton(
              onPressed: () => _startLivenessCheck(
                context,
                title: 'Dashed Circle - No Error Messages',
                config: LivenessCheckConfig(
                  theme: const LivenessCheckTheme(
                    borderStyle: CircleBorderStyle.dashed,
                    borderColor: Color(0xFF35C659),
                    borderWidth: 4,
                    dashLength: 8,
                    dashGap: 8,
                    cameraPadding: 10,
                  ),
                  settings: const LivenessCheckSettings(
                    showErrorMessage: false, // Hide error messages
                  ),
                  placeholder: "Vui lòng điều chỉnh khuôn mặt cho đến khi vòng tròn chuyển xanh",
                ),
              ),
              child: const Text('Hide Error Messages'),
            ),
            const SizedBox(height: 16),

            // Example 6: Success status with asset
            ElevatedButton(
              onPressed: () => _startLivenessCheck(
                context,
                title: 'Success Status with Asset',
                config: LivenessCheckConfig(
                  status: LivenessStatus.success,
                  theme: const LivenessCheckTheme(
                    borderStyle: CircleBorderStyle.solid,
                    successColor: Colors.green,
                    successAsset: 'assets/success.png', // Your success asset
                    circleSize: 0.6,
                    cameraPadding: 0,
                  ),
                  placeholder: "Liveness check successful!",
                ),
              ),
              child: const Text('Success Status with Asset'),
            ),
            const SizedBox(height: 16),

            // Example 7: Fail status with asset
            ElevatedButton(
              onPressed: () => _startLivenessCheck(
                context,
                title: 'Fail Status with Asset',
                config: LivenessCheckConfig(
                  status: LivenessStatus.fail,
                  theme: const LivenessCheckTheme(
                    borderStyle: CircleBorderStyle.dashed,
                    errorColor: Colors.red,
                    failAsset: 'assets/fail.png', // Your fail asset
                    dashLength: 6,
                    dashGap: 6,
                    circleSize: 0.6,
                    cameraPadding: 10,
                  ),
                  placeholder: "Liveness check failed. Please try again.",
                ),
              ),
              child: const Text('Fail Status with Asset'),
            ),
            const SizedBox(height: 32),

            const Text(
              'Circle Style Parameters:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• borderStyle: solid or dashed\n'
              '• dashLength: Length of each dash\n'
              '• dashGap: Gap between dashes\n'
              '• cameraPadding: Space between border and camera\n'
              '• circleSize: Size relative to screen width\n'
              '• borderWidth: Thickness of the border\n'
              '• borderColor: Color of the border',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _startLivenessCheck(BuildContext context, {required String title, required LivenessCheckConfig config}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessCheckScreen(config: config),
      ),
    );
  }
}