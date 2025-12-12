import 'dart:typed_data';

import './ulti/interpreter_utils.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart';

const _laplaceThreshold = 50;

class FaceAntiSpoofingService {
  static const clearnessThreshold = 1000;
  static const livenessThreshold = 0.2;

  static Future<FaceAntiSpoofingService> create() async {
    final interpreter = await Interpreter.fromAsset(
      'assets/FaceAntiSpoofing.tflite',
    );
    return FaceAntiSpoofingService._(interpreter);
  }

  final Interpreter _interpreter;

  FaceAntiSpoofingService._(this._interpreter);

  int laplacian(imglib.Image image) {
    var img = imglib.copyResize(image, width: 256, height: 256);
    img = imglib.grayscale(img);
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

  Future<bool> antiSpoofing(imglib.Image image) async {
    final clearness = laplacian(image);
    // Too blurry → reject (return false)
    if (clearness < FaceAntiSpoofingService.clearnessThreshold) return false;

    // Clear enough → proceed to anti-spoofing check
    final antiSpoofing = await liveness(image);
    // Low score = real face, high score = fake/spoof
    // Return true (pass) if score is below threshold (real face)
    if (antiSpoofing < FaceAntiSpoofingService.livenessThreshold) return true;
    return false;
  }

  Future<double> liveness(imglib.Image image) async {
    var input = _preProcess(image);
    input = input.reshape([1, 256, 256, 3]);
    var output = <int, Object>{};
    List clssPred = List.filled(1 * 8, 0.0).reshape([1, 8]);
    List leafNodeMask = List.filled(1 * 8, 0.0).reshape([1, 8]);
    final identityIndex = _interpreter.getOutputIndex("Identity");
    final identity1Index = _interpreter.getOutputIndex("Identity_1");
    output[identityIndex] = clssPred;
    output[identity1Index] = leafNodeMask;
    output = await _interpreter.runForMultipleInputsCompute([input], output);

    // Get the updated values from the returned output map
    clssPred = output[identityIndex] as List;
    leafNodeMask = output[identity1Index] as List;

    // Debug logging
    print('[FaceAntiSpoofing] clssPred: $clssPred');
    print('[FaceAntiSpoofing] leafNodeMask: $leafNodeMask');

    return _leafScore(clssPred, leafNodeMask);
  }

  double _leafScore(List clssPred, List leafNodeMask) {
    var score = 0.0;
    for (int i = 0; i < 8; i++) {
      score += ((clssPred[0][i] * leafNodeMask[0][i]) as double).abs();
    }
    print('[FaceAntiSpoofing] _leafScore calculated: $score');
    return score;
  }

  List _preProcess(imglib.Image image) {
    final img = imglib.copyResize(image, width: 256, height: 256);
    final imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  Float32List _imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 256 * 256 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    var pixelIndex = 0;
    for (var i = 0; i < 256; i++) {
      for (var j = 0; j < 256; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = pixel.r / 255;
        buffer[pixelIndex++] = pixel.g / 255;
        buffer[pixelIndex++] = pixel.b / 255;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }
}
