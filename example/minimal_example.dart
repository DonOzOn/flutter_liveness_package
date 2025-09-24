import 'package:flutter/material.dart';
import 'package:flutter_liveness_check/flutter_liveness_check.dart';

/// Minimal example with just the essential configuration
class MinimalExample extends StatefulWidget {
  const MinimalExample({super.key});

  @override
  State<MinimalExample> createState() => _MinimalExampleState();
}

class _MinimalExampleState extends State<MinimalExample> {
  LivenessStatus _status = LivenessStatus.init;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minimal Liveness Check')),
      body: LivenessCheckScreen(
        config: LivenessCheckConfig(
          status: _status,
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

/// Quick demo showing all three states
class AllStatesDemo extends StatefulWidget {
  const AllStatesDemo({super.key});

  @override
  State<AllStatesDemo> createState() => _AllStatesDemoState();
}

class _AllStatesDemoState extends State<AllStatesDemo> {
  LivenessStatus _status = LivenessStatus.init;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All States Demo'),
        actions: [
          PopupMenuButton<LivenessStatus>(
            onSelected: (status) => setState(() => _status = status),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: LivenessStatus.init,
                child: Text('Init State'),
              ),
              const PopupMenuItem(
                value: LivenessStatus.success,
                child: Text('Success State'),
              ),
              const PopupMenuItem(
                value: LivenessStatus.fail,
                child: Text('Fail State'),
              ),
            ],
          ),
        ],
      ),
      body: LivenessCheckScreen(
        config: LivenessCheckConfig(
          status: _status,
          placeholder: "Current status: ${_status.name}",
          callbacks: LivenessCheckCallbacks(
            onTryAgain: () => setState(() => _status = LivenessStatus.init),
          ),
        ),
      ),
    );
  }
}