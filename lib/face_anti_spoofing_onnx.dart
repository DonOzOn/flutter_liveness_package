import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'package:onnxruntime/onnxruntime.dart';

/// ONNX-based Face Anti-Spoofing Service
/// Uses the anti-spoof-mn3.onnx model for liveness detection
class FaceAntiSpoofingOnnx {
  // Instance variable for configurable clearness threshold
  final int clearnessThreshold;

  // Threshold for liveness score
  // For MobileNet v3 anti-spoof: score > threshold = real face, score <= threshold = fake
  // Platform-specific thresholds using static getters
  static double get livenessThreshold => Platform.isIOS ? 0.3 : 0.7;
  static double get spoofThreshold => Platform.isIOS ? 0.98 : 0.9;
  // Laplace threshold for blur detection
  static const _laplaceThreshold = 50;

  late final OrtSession _session;
  late final OrtSessionOptions _sessionOptions;

  /// Creates and initializes the ONNX anti-spoofing service
  /// [clearnessThreshold] - Minimum clearness score for image quality (default: 800)
  static Future<FaceAntiSpoofingOnnx> create({int clearnessThreshold = 800}) async {
    final service = FaceAntiSpoofingOnnx._(clearnessThreshold: clearnessThreshold);
    await service._initialize();
    return service;
  }

  FaceAntiSpoofingOnnx._({this.clearnessThreshold = 800});

  Future<void> _initialize() async {
    // Initialize ONNX Runtime
    OrtEnv.instance.init();

    // Load model from assets with package prefix for use as a dependency
    final modelBytes =
        await rootBundle.load('packages/flutter_liveness_check/assets/w.onnx');
    final modelData = modelBytes.buffer.asUint8List();

    // Create session options
    _sessionOptions = OrtSessionOptions();

    // Create session
    _session = OrtSession.fromBuffer(modelData, _sessionOptions);

    debugPrint('[ONNX AntiSpoof] Model loaded successfully');
    debugPrint('[ONNX AntiSpoof] Input names: ${_session.inputNames}');
    debugPrint('[ONNX AntiSpoof] Output names: ${_session.outputNames}');
  }

  /// Performs complete anti-spoofing check on an image
  /// Returns true if the image is a real face, false if it's a spoof/fake
  Future<bool> antiSpoofing(imglib.Image image) async {
    // Step 1: Check if image is clear enough
    // final clearness = FaceAntiSpoofingOnnx.calculateLaplacian(image);
    // debugPrint('[ONNX AntiSpoof] Clearness score: $clearness');

    // if (clearness < clearnessThreshold) {
    //   debugPrint(
    //       '[ONNX AntiSpoof] Image too blurry (clearness: $clearness < $clearnessThreshold)');
    //   return false;
    // }

    // Step 2: Run liveness detection
    final isReal = await checkLiveness(image);
    debugPrint('[ONNX AntiSpoof] Liveness score: $isReal');

    debugPrint(
        '[ONNX AntiSpoof] Result: ${isReal ? "REAL FACE" : "FAKE/SPOOF"}');

    return isReal;
  }

  /// Runs the ONNX model to get liveness score
  /// Returns a score between 0 and 1, where higher = more likely to be real
  Future<bool> checkLiveness(imglib.Image image) async {
    // Preprocess image to model input format
    final input = _preprocessImage(image);
    final runOptions = OrtRunOptions();
    // Create input tensor
    // Model expects [1, 3, 256, 256] based on training config (resize = dict(height=256, width=256))
    final inputOrt = OrtValueTensor.createTensorWithDataList(
      input,
      [1, 3, 256, 256], // Shape: [batch, channels, height, width]
    );

    // Run inference
    final inputs = {_session.inputNames.first: inputOrt};
    final outputs = await _session.runAsync(
      runOptions,
      inputs,
    );

    // Get output
    final outputTensor = outputs?.first;
    if (outputTensor == null) {
      throw Exception('No output from model');
    }

    // Extract score from output
    final outputData = outputTensor.value as List<List<double>>;
    debugPrint('[ONNX AntiSpoof] Raw output: $outputData');
    debugPrint(
        '[ONNX AntiSpoof] outputData[0].length: ${outputData[0].length}');

    // The output format depends on your model
    // Common formats:
    // 1. [batch, 2] - probabilities for [fake, real]
    // 2. [batch, 1] - single confidence score
    bool isReal = false;
    if (outputData[0].length == 2) {
      List<double> out = outputData[0];
      double realProb = out[0];
      // double spoofProb = out[1];
      if (realProb >= livenessThreshold) {
        isReal = true;
      }
      // Binary classification: [fake_prob, real_prob]
      // score = spoofProb; // Real face probability
    } else if (outputData[0].length == 1) {
      // Single score output
      // score = outputData[0][0];
    } else if (outputData[0].length == 3) {
      final fakeProb = outputData[0][0]; // Index 0
      final realProb = outputData[0][1]; // Index 1
      final unknownProb = outputData[0][2]; // Index 2

      debugPrint(
          '[ONNX AntiSpoof] Fake: $fakeProb, Real: $realProb, Unknown: $unknownProb');

      // Method 1: Use argmax (like original code)
      final maxIndex =
          outputData[0].indexOf(outputData[0].reduce((a, b) => a > b ? a : b));

      if (maxIndex == 1) {
        isReal = true;
        debugPrint(
            '[ONNX AntiSpoof] outputData[0].length == 3 Decision: REAL (argmax = 1)');
      } else {
        // Method 2: Fallback - compare real vs fake directly
        // Use this if argmax doesn't work well
        if (realProb > fakeProb) {
          isReal = true;
          debugPrint(
              '[ONNX AntiSpoof]outputData[0].length == 3 Decision: REAL (realProb > fakeProb)');
        } else {
          debugPrint(
              '[ONNX AntiSpoof]outputData[0].length == 3 Decision: FAKE');
        }
      }

      // Multi-class: take max or specific index
      // score = outputData[0].reduce((a, b) => a > b ? a : b);
    }

    // Release resources
    inputOrt.release();
    outputTensor.release();
    runOptions.release();
    return isReal;
  }

  /// Calculates Laplacian score to detect image blur
  static int calculateLaplacian(imglib.Image image) {
    var img = imglib.copyResize(image, width: 256, height: 256);
    img = imglib.grayscale(img);

    // Laplacian kernel
    var laplace = [
      [0, 1, 0],
      [1, -4, 1],
      [0, 1, 0],
    ];

    int size = laplace.length;
    int score = 0;

    for (int x = 0; x < 256 - size + 1; x++) {
      for (int y = 0; y < 256 - size + 1; y++) {
        int result = 0;
        for (int i = 0; i < size; i++) {
          for (int j = 0; j < size; j++) {
            var color = img.getPixel(x + i, y + j);
            var pixel = color.r.toInt();
            result += (pixel & 0xFF) * laplace[i][j];
          }
        }
        if (result > _laplaceThreshold) {
          score++;
        }
      }
    }

    return score;
  }

  /// Preprocesses image to model input format
  /// MobileNet v3 expects CHW format with custom normalization
  /// Based on training config: img_norm_cfg = dict(mean=[0.5931, 0.4690, 0.4229], std=[0.2471, 0.2214, 0.2157])
  /// Returns Float32List for ONNX Runtime compatibility
  Float32List _preprocessImage(imglib.Image image) {
    final img = imglib.copyResize(image, width: 256, height: 256);

    // Prepare data in CHW format (channels, height, width)
    // Normalization: (pixel/255.0 - mean) / std
    final data = Float32List(256 * 256 * 3);
    int index = 0;

    // Normalization values from training config
    const mean = [0.5931, 0.4690, 0.4229];
    const std = [0.2471, 0.2214, 0.2157];

    // Extract R channel
    for (int y = 0; y < 256; y++) {
      for (int x = 0; x < 256; x++) {
        var pixel = img.getPixel(x, y);
        data[index++] = ((pixel.r / 255.0 - mean[0]) / std[0]);
      }
    }

    // Extract G channel
    for (int y = 0; y < 256; y++) {
      for (int x = 0; x < 256; x++) {
        var pixel = img.getPixel(x, y);
        data[index++] = ((pixel.g / 255.0 - mean[1]) / std[1]);
      }
    }

    // Extract B channel
    for (int y = 0; y < 256; y++) {
      for (int x = 0; x < 256; x++) {
        var pixel = img.getPixel(x, y);
        data[index++] = ((pixel.b / 255.0 - mean[2]) / std[2]);
      }
    }

    return data;
  }

  /// Releases resources
  void dispose() {
    _session.release();
    _sessionOptions.release();
    OrtEnv.instance.release();
  }
}
