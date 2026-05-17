import '../services/api_service.dart';

/// Groq API service that acts as a wrapper around the Railway backend
class GroqService {
  static final ApiService _apiService = ApiService();

  static Future<Map<String, dynamic>> analyzeText(String text, String mode, String userId) async {
    try {
      final response = await _apiService.analyzeChat(chatText: text);
      return response;
    } catch (e) {
      throw Exception('Failed to analyze text: $e');
    }
  }

  static Future<Map<String, dynamic>> generateReplies(String text, String mode, int count) async {
    try {
      final response = await _apiService.generateReplies(
        chatText: text,
        mode: mode,
        lastMessage: text.split('\n').last, // Rough approximation
      );
      return response;
    } catch (e) {
      throw Exception('Failed to generate replies: $e');
    }
  }
}