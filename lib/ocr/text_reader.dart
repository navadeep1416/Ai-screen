import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Text reader using Google ML Kit
class TextReader {
  static final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Read text from image path
  static Future<String> readFromPath(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final recognizedText = await _recognizer.processImage(inputImage);
      await inputImage.close();
      return recognizedText.text;
    } catch (e) {
      print('Text recognition error: $e');
      return '';
    }
  }

  /// Read text from bytes
  static Future<String> readFromBytes(Uint8List bytes) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: const Size(640, 480),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: 640 * 4,
        ),
      );
      final recognizedText = await _recognizer.processImage(inputImage);
      await inputImage.close();
      return recognizedText.text;
    } catch (e) {
      print('Text recognition error: $e');
      return '';
    }
  }

  /// Extract specific text regions
  static Future<RecognizedText> readWithDetails(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final result = await _recognizer.processImage(inputImage);
      await inputImage.close();
      return result;
    } catch (e) {
      print('Text recognition error: $e');
      rethrow;
    }
  }

  /// Dispose the recognizer
  static void dispose() {
    _recognizer.close();
  }
}