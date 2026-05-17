import '../core/constants/app_constants.dart';
import 'mood_detector.dart';
import 'flirt_detector.dart';
import 'engagement_detector.dart';

/// Relationship engine - combines all analysis for relationship insights
class RelationshipEngine {
  RelationshipEngine._();

  /// Analyze relationship based on chat messages
  static RelationshipAnalysis analyze(
    List<String> messages, {
    String? currentMode,
  }) {
    if (messages.isEmpty) {
      return RelationshipAnalysis(
        detectedMode: RelationshipMode.stranger,
        matchPercent: 50,
        interestLevel: 50,
        energyLevel: 5,
        emotions: ['Neutral'],
        insights: ['No conversation data'],
        aiAdvice: 'Start a conversation to get insights',
      );
    }

    final latestMessage = messages.last;

    // Combine all detection results
    final moodResult = MoodDetector.detectMood(latestMessage);
    final flirtResult = FlirtDetector.detect(latestMessage);
    final engagementResult = EngagementDetector.detect(latestMessage, previousMessages: messages.take(5).toList());

    // Determine relationship mode
    final detectedMode = _determineMode(
      flirtResult: flirtResult,
      moodResult: moodResult,
      engagementResult: engagementResult,
      currentMode: currentMode,
    );

    // Calculate metrics
    final interestLevel = _calculateInterest(flirtResult, engagementResult);
    final energyLevel = _calculateEnergy(moodResult, engagementResult, latestMessage);

    // Generate insights
    final insights = <String>[];
    insights.addAll(flirtResult.indicators.map((i) => 'Flirting: $i'));
    insights.addAll(engagementResult.insights);

    // Generate advice
    final advice = _generateAdvice(detectedMode, interestLevel, moodResult);

    return RelationshipAnalysis(
      detectedMode: detectedMode,
      matchPercent: _calculateMatch(detectedMode, currentMode),
      interestLevel: interestLevel,
      energyLevel: energyLevel,
      emotions: moodResult,
      insights: insights,
      aiAdvice: advice,
    );
  }

  static RelationshipMode _determineMode({
    required FlirtResult flirtResult,
    required List<String> moodResult,
    required EngagementResult engagementResult,
    String? currentMode,
  }) {
    if (flirtResult.score > 50 && moodResult.any((m) => m == 'Flirty' || m == 'Happy')) {
      return RelationshipMode.crush;
    }
    if (engagementResult.level == EngagementLevel.low) {
      return RelationshipMode.stranger;
    }
    if (moodResult.contains('Sad') || moodResult.contains('Angry')) {
      return RelationshipMode.fight;
    }

    return currentMode != null
        ? RelationshipMode.fromString(currentMode)
        : RelationshipMode.friend;
  }

  static int _calculateInterest(FlirtResult flirt, EngagementResult engagement) {
    return ((flirt.score * 0.4) + (engagement.score * 0.6)).round().clamp(0, 100);
  }

  static double _calculateEnergy(List<String> mood, EngagementResult engagement, String text) {
    double energy = 5.0;

    if (mood.contains('Excited') || mood.contains('Happy')) energy += 2;
    if (mood.contains('Sad') || mood.contains('Angry')) energy -= 1;

    energy += (engagement.score / 20).clamp(-2, 2);

    if (text.contains('!')) energy += 0.5;
    if (text.length > 50) energy += 0.5;

    return energy.clamp(1, 10);
  }

  static int _calculateMatch(RelationshipMode detected, String? current) {
    if (current == null) return 70;
    if (detected.name.toLowerCase() == current.toLowerCase().replaceAll(' ', '')) return 90;
    return 65;
  }

  static String _generateAdvice(RelationshipMode mode, int interest, List<String> emotions) {
    if (interest > 70) {
      return 'They seem interested! Keep the conversation engaging.';
    }
    if (emotions.contains('Sad')) {
      return 'They might need support. Be empathetic and understanding.';
    }
    if (mode == RelationshipMode.crush) {
      return 'Flirtatious vibes detected. Keep it playful and confident!';
    }
    return 'Continue the conversation naturally.';
  }
}

class RelationshipAnalysis {
  final RelationshipMode detectedMode;
  final int matchPercent;
  final int interestLevel;
  final double energyLevel;
  final List<String> emotions;
  final List<String> insights;
  final String aiAdvice;

  RelationshipAnalysis({
    required this.detectedMode,
    required this.matchPercent,
    required this.interestLevel,
    required this.energyLevel,
    required this.emotions,
    required this.insights,
    required this.aiAdvice,
  });

  Map<String, dynamic> toMap() => {
    'detectedMode': detectedMode.name,
    'matchPercent': matchPercent,
    'interestLevel': interestLevel,
    'energyLevel': energyLevel,
    'emotions': emotions,
    'insights': insights,
    'aiAdvice': aiAdvice,
  };
}