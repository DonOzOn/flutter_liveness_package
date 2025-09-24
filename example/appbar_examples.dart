import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

class AppBarExamples extends StatelessWidget {
  const AppBarExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppBar Configuration Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _showDefaultAppBar(context),
              child: const Text('Default AppBar'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showNoBackButton(context),
              child: const Text('No Back Button'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCustomBackIcon(context),
              child: const Text('Custom Back Icon'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showBrandedAppBar(context),
              child: const Text('Branded AppBar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDefaultAppBar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LivenessCheckScreen(
          config: LivenessCheckConfig(
            appBarConfig: AppBarConfig(
              title: 'Default AppBar',
              centerTitle: true,
              showBackButton: true, // Default behavior
            ),
          ),
        ),
      ),
    );
  }

  void _showNoBackButton(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessCheckScreen(
          config: LivenessCheckConfig(
            appBarConfig: const AppBarConfig(
              title: 'No Back Button',
              centerTitle: true,
              showBackButton: false, // Hide back button
            ),
            // Custom bottom widget to provide navigation
            customBottomWidget: Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomBackIcon(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessCheckScreen(
          config: LivenessCheckConfig(
            appBarConfig: AppBarConfig(
              title: 'Custom Back Icon',
              centerTitle: true,
              showBackButton: true,
              customBackIcon: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  // Custom close action
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancel Verification?'),
                      content: const Text('Are you sure you want to cancel the liveness check?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Close liveness screen
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            theme: const LivenessCheckTheme(
              primaryColor: Colors.red,
              borderColor: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  void _showBrandedAppBar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessCheckScreen(
          config: LivenessCheckConfig(
            appBarConfig: AppBarConfig(
              title: 'SecureBank Verification',
              centerTitle: true,
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              backgroundColor: const Color(0xFF1565C0),
              elevation: 4,
              showBackButton: true,
              customBackIcon: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification cancelled by user'),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 20,
                      ),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            theme: const LivenessCheckTheme(
              backgroundColor: Color(0xFFF8F9FA),
              primaryColor: Color(0xFF1565C0),
              successColor: Color(0xFF2E7D32),
              errorColor: Color(0xFFD32F2F),
              textColor: Color(0xFF1A1A1A),
            ),
            callbacks: LivenessCheckCallbacks(
              onCancel: () {
                debugPrint('User cancelled verification from branded app');
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Example of different AppBar configurations
class AppBarConfigExamples extends StatelessWidget {
  const AppBarConfigExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppBar Config Variations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleCard(
            'Standard Back Button',
            'Default back arrow with standard behavior',
            () => _launchExample(
              context,
              const AppBarConfig(
                title: 'Standard Back',
                showBackButton: true,
              ),
            ),
          ),
          _buildExampleCard(
            'No Back Button',
            'AppBar without any back navigation',
            () => _launchExample(
              context,
              const AppBarConfig(
                title: 'No Back Button',
                showBackButton: false,
              ),
            ),
          ),
          _buildExampleCard(
            'Custom Close Icon',
            'Custom close icon instead of back arrow',
            () => _launchExample(
              context,
              AppBarConfig(
                title: 'Custom Close',
                showBackButton: true,
                customBackIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          _buildExampleCard(
            'Left-aligned Title',
            'Title aligned to the left with back button',
            () => _launchExample(
              context,
              const AppBarConfig(
                title: 'Left Title',
                centerTitle: false,
                showBackButton: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String title, String description, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _launchExample(BuildContext context, AppBarConfig config) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessCheckScreen(
          config: LivenessCheckConfig(
            appBarConfig: config,
            placeholder: 'Example: ${config.title}',
          ),
        ),
      ),
    );
  }
}