import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

/// Screen capture service using native MediaProjection
class ScreenCapture {
  static const MethodChannel _channel = MethodChannel('com.navascreen.ai/screencapture');

  /// Capture a screenshot
  static Future<String?> captureScreen() async {
    try {
      final String? imagePath = await _channel.invokeMethod('captureScreen');
      return imagePath;
    } catch (e) {
      print('Screen capture error: $e');
      return null;
    }
  }

  /// Start continuous screen capture
  static Stream<String?> startCaptureStream({Duration interval = const Duration(seconds: 3)}) {
    return Stream.periodic(interval).asyncMap((_) => captureScreen());
  }

  /// Stop capture stream
  static Future<void> stopCapture() async {
    try {
      await _channel.invokeMethod('stopCapture');
    } catch (e) {
      print('Stop capture error: $e');
    }
  }

  /// Check if screen capture is available
  static Future<bool> isAvailable() async {
    try {
      final bool available = await _channel.invokeMethod('isAvailable');
      return available;
    } catch (e) {
      return false;
    }
  }

  /// Request screen capture permission
  static Future<bool> requestPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('requestPermission');
      return granted;
    } catch (e) {
      return false;
    }
  }
}