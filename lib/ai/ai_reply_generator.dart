import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import 'groq_service.dart';
import 'mode_engine.dart';

/// AI Reply generator service
class AIReplyGenerator {
  /// Generate replies for given text and mode
  static Future<List<Map<String, String>>> generate({
    required String text,
    required String mode,
    int count = 3,
  }) async {
    try {
      // Use Groq service to generate
      final result = await GroqService.generateReplies(text, mode, count);

      return (result['replies'] as List).map((r) => {
        'style': r['style'] as String,
        'text': r['text'] as String,
      }).toList();
    } catch (e) {
      throw Exception('Failed to generate replies: $e');
    }
  }

  /// Generate variations of a reply
  static Future<List<String>> generateVariations(String reply, String style) async {
    // In production, this would call the AI again with variation prompt
    return [reply, 'Variation 2', 'Variation 3'];
  }

  /// Score reply quality
  static double scoreReply(String reply, String mode) {
    double score = 0.5;

    // Check reply length (prefer medium length)
    if (reply.length > 10 && reply.length < 100) score += 0.1;

    // Check for emoji usage (varies by mode)
    final hasEmoji = reply.contains(RegExp(r'[\u{1F300}-\u{1F9FF}]'));
    if (mode == 'Crush' || mode == 'Love') {
      if (hasEmoji) score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Select best reply based on context
  static String selectBestReply(List<Map<String, String>> replies, String context) {
    // Simple selection - in production use more sophisticated logic
    return replies.first['text'] ?? replies.first['text']!;
  }
}