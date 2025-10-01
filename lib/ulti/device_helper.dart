import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Checks if the current device is manufactured by Xiaomi or its sub-brands.
///
/// This function detects Xiaomi devices including:
/// - Xiaomi branded devices
/// - Redmi devices
/// - POCO devices
/// - Mi devices
///
/// Returns `true` if the device is a Xiaomi device, `false` otherwise.
/// Returns `false` for non-Android platforms or if device info cannot be retrieved.
Future<bool> isXiaomiDevice() async {
  try {
    if (!Platform.isAndroid) {
      return false;
    }

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final manufacturer = androidInfo.manufacturer.toLowerCase().trim();
    final brand = androidInfo.brand.toLowerCase().trim();

    // List of Xiaomi-related manufacturers and brands
    const xiaomiIdentifiers = [
      'xiaomi',
      'redmi',
      'poco',
      'mi',
    ];

    // Check if manufacturer or brand matches any Xiaomi identifier
    return xiaomiIdentifiers.any((identifier) =>
        manufacturer.contains(identifier) || brand.contains(identifier));
  } catch (e) {
    // Log error if needed, return false as fallback
    return false;
  }
}
