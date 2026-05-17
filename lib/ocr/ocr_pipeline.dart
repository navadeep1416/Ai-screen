import 'dart:async';
import 'package:flutter/foundation.dart';
import 'screen_capture.dart';
import 'text_reader.dart';
import 'chat_parser.dart';

class OcrPipeline {
  bool _isProcessing = false;
  String _lastProcessedText = '';

  Future<ChatData?> processScreen() async {
    if (_isProcessing) return null;
    
    _isProcessing = true;
    final stopwatch = Stopwatch()..start();
    try {
      debugPrint('[OCR Pipeline] Starting screen capture...');
      final imagePath = await ScreenCapture.captureScreen();
      if (imagePath == null) {
        debugPrint('[OCR Pipeline] Screen capture failed or returned null.');
        return null;
      }
      debugPrint('[OCR Pipeline] Screen capture took: ${stopwatch.elapsedMilliseconds}ms');

      final extractionTimer = Stopwatch()..start();
      final recognizedText = await TextReader.readFromPath(imagePath);
      debugPrint('[OCR Pipeline] Text extraction took: ${extractionTimer.elapsedMilliseconds}ms');
      
      if (recognizedText.isEmpty) {
        debugPrint('[OCR Pipeline] No text extracted.');
        return null;
      }

      debugPrint('[OCR Pipeline] Extracted Text Snippet: ${recognizedText.substring(0, recognizedText.length > 50 ? 50 : recognizedText.length)}...');

      // Basic debounce/deduplication based on exact match of raw text
      if (recognizedText == _lastProcessedText) {
        debugPrint('[OCR Pipeline] Duplicate OCR text. Skipping API call.');
        return null;
      }

      _lastProcessedText = recognizedText;
      final parsedChat = ChatParser.parse(recognizedText);

      debugPrint('[OCR Pipeline] Parsed ${parsedChat.messages.length} messages.');
      if (parsedChat.messages.isNotEmpty) {
        debugPrint('[OCR Pipeline] Latest message from: ${parsedChat.messages.last.sender}');
      }

      return parsedChat;
    } catch (e) {
      debugPrint('[OCR Pipeline] Error: $e');
      return null;
    } finally {
      _isProcessing = false;
      stopwatch.stop();
      debugPrint('[OCR Pipeline] Total loop time: ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  void reset() {
    _lastProcessedText = '';
    _isProcessing = false;
    debugPrint('[OCR Pipeline] Reset pipeline state.');
  }
}

