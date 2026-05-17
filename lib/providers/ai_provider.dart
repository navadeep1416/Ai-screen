import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../ai/groq_service.dart';
import '../ai/ai_reply_generator.dart';
import '../analysis/relationship_engine.dart';

/// AI Provider for state management
class AIProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  RelationshipAnalysis? _currentAnalysis;
  List<Map<String, String>> _suggestedReplies = [];
  String _currentMode = 'Crush';

  bool get isLoading => _isLoading;
  String? get error => _error;
  RelationshipAnalysis? get currentAnalysis => _currentAnalysis;
  List<Map<String, String>> get suggestedReplies => _suggestedReplies;
  String get currentMode => _currentMode;

  /// Update current mode
  void setMode(String mode) {
    _currentMode = mode;
    notifyListeners();
  }

  /// Analyze text with AI
  Future<void> analyzeText(String text) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use Groq service for analysis
      final result = await GroqService.analyzeText(text, _currentMode, 'user');
      _currentAnalysis = RelationshipAnalysis(
        detectedMode: RelationshipMode.fromString(result['analysis']?['detectedMode'] ?? _currentMode),
        matchPercent: result['analysis']?['matchPercent'] ?? 70,
        interestLevel: result['analysis']?['interestLevel'] ?? 50,
        energyLevel: (result['analysis']?['energyLevel'] ?? 5.0).toDouble(),
        emotions: List<String>.from(result['analysis']?['emotions'] ?? ['Neutral']),
        insights: List<String>.from(result['analysis']?['insights'] ?? ['Analyzing...']),
        aiAdvice: result['analysis']?['aiAdvice'] ?? 'Continue the conversation',
      );

      // Generate replies
      _suggestedReplies = await AIReplyGenerator.generate(
        text: text,
        mode: _currentMode,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generate new replies
  Future<void> regenerateReplies(String text) async {
    _isLoading = true;
    notifyListeners();

    try {
      _suggestedReplies = await AIReplyGenerator.generate(
        text: text,
        mode: _currentMode,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear analysis
  void clear() {
    _currentAnalysis = null;
    _suggestedReplies = [];
    _error = null;
    notifyListeners();
  }
}