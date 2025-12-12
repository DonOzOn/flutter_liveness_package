import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as imglib;

class CameraImageConverter {
  /// Convert CameraImage (YUV420 format) to imglib.Image
  static imglib.Image? cameraImageToImage(CameraImage cameraImage) {
    try {
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420ToImage(cameraImage);
      } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888ToImage(cameraImage);
      } else if (cameraImage.format.group == ImageFormatGroup.jpeg) {
        return _convertJPEGToImage(cameraImage);
      } else {
        // Fallback for other formats
        return _convertUsingPlanes(cameraImage);
      }
    } catch (e) {
      debugPrint('Error converting CameraImage: $e');
      return null;
    }
  }

  /// Convert YUV420 to RGB Image
  static imglib.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    // For YUV420, we have Y plane and UV plane
    final yPlane = cameraImage.planes[0].bytes;
    final uPlane = cameraImage.planes[1].bytes;
    final vPlane = cameraImage.planes[2].bytes;

    // Create empty image
    final img = imglib.Image(width: width, height: height);

    // Convert YUV to RGB
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * cameraImage.planes[0].bytesPerRow + x;
        final uvIndex = (y ~/ 2) * cameraImage.planes[1].bytesPerRow + (x ~/ 2);

        final yValue = yPlane[yIndex];
        final uValue = uPlane[uvIndex];
        final vValue = vPlane[uvIndex];

        // Convert YUV to RGB
        final r = _yuv2r(yValue, uValue, vValue);
        final g = _yuv2g(yValue, uValue, vValue);
        final b = _yuv2b(yValue, uValue, vValue);

        img.setPixelRgb(x, y, r, g, b);
      }
    }

    return img;
  }

  /// Convert BGRA8888 to RGB Image
  static imglib.Image _convertBGRA8888ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    if (cameraImage.planes.length != 1) {
      throw Exception('Expected 1 plane for BGRA8888');
    }

    final bytes = cameraImage.planes[0].bytes;
    final img = imglib.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = (y * cameraImage.planes[0].bytesPerRow) + (x * 4);

        // BGRA format
        final b = bytes[index];
        final g = bytes[index + 1];
        final r = bytes[index + 2];
        // final a = bytes[index + 3]; // Alpha channel, ignore for RGB

        img.setPixelRgb(x, y, r, g, b);
      }
    }

    return img;
  }

  /// Convert JPEG to Image
  static imglib.Image _convertJPEGToImage(CameraImage cameraImage) {
    if (cameraImage.planes.length != 1) {
      throw Exception('Expected 1 plane for JPEG');
    }

    final bytes = cameraImage.planes[0].bytes;
    return imglib.decodeImage(bytes) ?? imglib.Image(width: 1, height: 1);
  }

  /// Generic conversion using planes
  static imglib.Image _convertUsingPlanes(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final img = imglib.Image(width: width, height: height);

    // This is a simplified conversion - may need adjustment based on format
    final plane = cameraImage.planes[0];
    final bytes = plane.bytes;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * plane.bytesPerRow + x;

        if (index < bytes.length) {
          final gray = bytes[index];
          img.setPixelRgb(x, y, gray, gray, gray);
        }
      }
    }

    return img;
  }

  /// YUV to RGB conversion helpers
  static int _yuv2r(int y, int u, int v) {
    var r = (y + (1.402 * (v - 128))).toInt();
    return r.clamp(0, 255);
  }

  static int _yuv2g(int y, int u, int v) {
    var g = (y - (0.344 * (u - 128)) - (0.714 * (v - 128))).toInt();
    return g.clamp(0, 255);
  }

  static int _yuv2b(int y, int u, int v) {
    var b = (y + (1.772 * (u - 128))).toInt();
    return b.clamp(0, 255);
  }

  /// Alternative: Convert CameraImage to Uint8List (simpler but may be slower)
  static Future<Uint8List?> cameraImageToBytes(CameraImage cameraImage) async {
    try {
      // Convert CameraImage to ui.Image first
      final uiImage = await _cameraImageToUiImage(cameraImage);

      // Convert ui.Image to ByteData
      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error converting CameraImage to bytes: $e');
      return null;
    }
  }

  static Future<ui.Image> _cameraImageToUiImage(CameraImage cameraImage) async {
    final completer = Completer<ui.Image>();

    ui.decodeImageFromList(
      Uint8List.fromList(
        await _convertToPNG(cameraImage),
      ),
      (ui.Image image) {
        completer.complete(image);
      },
    );

    return completer.future;
  }

  static Future<List<int>> _convertToPNG(CameraImage cameraImage) async {
    final img = cameraImageToImage(cameraImage);
    if (img == null) {
      return [];
    }
    return imglib.encodePng(img);
  }
}
