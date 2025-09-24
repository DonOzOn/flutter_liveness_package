// Result Screen
import 'dart:io';

import 'package:flutter/material.dart';

class LivenessResultScreen extends StatelessWidget {
  final String imagePath;

  const LivenessResultScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verification Complete'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 50,
                color: Colors.green.shade600,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Liveness Check Passed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Your identity has been verified successfully.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Captured image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: .3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(imagePath), fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Retake',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle continue action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification completed successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
