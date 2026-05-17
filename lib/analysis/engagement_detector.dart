/// Engagement detection service
class EngagementDetector {
  EngagementDetector._();

  /// Detect engagement level from text
  static EngagementResult detect(String text, {List<String>? previousMessages}) {
    final lowerText = text.toLowerCase();
    int score = 0;
    final insights = <String>[];

    // Positive engagement indicators
    if (lowerText.contains('?') || lowerText.contains('what') || lowerText.contains('how')) {
      score += 15;
      insights.add('Asking questions');
    }

    if (lowerText.length > 20) {
      score += 10;
      insights.add('Detailed responses');
    }

    // Check for emoji usage
    final emojis = RegExp(r'[\u{1F300}-\u{1F9FF}]').allMatches(text);
    if (emojis.isNotEmpty) {
      score += 10;
      insights.add('Using emojis');
    }

    // Response time patterns (would need timestamp data in production)
    // Check for active phrases
    final activePhrases = ['tell me', 'what do you think', 'honestly', 'really'];
    for (final phrase in activePhrases) {
      if (lowerText.contains(phrase)) {
        score += 10;
        insights.add('Engaged in conversation');
      }
    }

    // Negative indicators
    if (text == 'ok' || text == 'k' || text == '👍' || text.length < 5) {
      score -= 10;
      insights.add('Short response - might be busy');
    }

    // Check for questions in previous messages
    if (previousMessages != null) {
      final hasQuestion = previousMessages.any((m) => m.contains('?'));
      if (hasQuestion) {
        score += 10;
        insights.add('Initiated conversation');
      }
    }

    return EngagementResult(
      score: score.clamp(0, 100),
      level: _getLevel(score),
      insights: insights,
    );
  }

  static EngagementLevel _getLevel(int score) {
    if (score > 70) return EngagementLevel.high;
    if (score > 40) return EngagementLevel.medium;
    return EngagementLevel.low;
  }
}

class EngagementResult {
  final int score;
  final EngagementLevel level;
  final List<String> insights;

  EngagementResult({required this.score, required this.level, required this.insights});
}

enum EngagementLevel { low, medium, high }