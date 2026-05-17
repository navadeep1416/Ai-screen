import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Production-ready API service for Nava Screen AI
class ApiService {
  static final http.Client _client = http.Client();
  static const int timeoutSeconds = 15;

  /// Generic POST method to reduce boilerplate
  static Future<Map<String, dynamic>> _post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('[API] Error response from $endpoint: ${response.body}');
        throw ApiException(
          'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint('[API] Exception during $endpoint: $e');
      throw ApiException('Network error: $e');
    }
  }

  /// Generates 3 smart reply suggestions based on chat context and relationship mode.
  Future<Map<String, dynamic>> generateReplies({
    required String chatText,
    required String mode,
    required String lastMessage,
  }) async {
    debugPrint('[API] Requesting /generate-replies');
    return await _post('/generate-replies', body: {
      'chatText': chatText,
      'mode': mode,
      'lastMessage': lastMessage,
    });
  }

  /// Analyzes the conversation for mood, interest level, and flirting score.
  Future<Map<String, dynamic>> analyzeChat({
    required String chatText,
  }) async {
    debugPrint('[API] Requesting /analyze-chat');
    return await _post('/analyze-chat', body: {
      'chatText': chatText,
    });
  }

  /// Detects the overall emotional mood of the conversation.
  Future<Map<String, dynamic>> analyzeMood({
    required String chatText,
  }) async {
    debugPrint('[API] Requesting /analyze-mood');
    return await _post('/analyze-mood', body: {
      'chatText': chatText,
    });
  }

  /// Analyzes a reel or screenshot using Vision AI.
  Future<Map<String, dynamic>> analyzeReel({
    required String imageUrl,
  }) async {
    debugPrint('[API] Requesting /analyze-reel');
    return await _post('/analyze-reel', body: {
      'imageUrl': imageUrl,
    });
  }
}
