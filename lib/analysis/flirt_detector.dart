/// Flirt detection service
class FlirtDetector {
  FlirtDetector._();

  /// Detect if text contains flirting indicators
  static FlirtResult detect(String text) {
    final lowerText = text.toLowerCase();
    int score = 0;
    final indicators = <String>[];

    // Flirt keywords
    final flirtKeywords = {
      'Compliments': ['beautiful', 'cute', 'pretty', 'gorgeous', 'hot', 'sexy', 'amazing'],
      'Interest': ['miss you', 'thinking about you', 'can\'t stop thinking', 'you\'re funny'],
      'Playful': ['😏', 'wink', 'teasing', 'challenging'],
      'Affection': ['love', 'adore', 'crush', '❤️', '💖', '💕'],
      'Future': ['can\'t wait to', 'hope to', 'should meet', 'hang out'],
    };

    for (final entry in flirtKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          score += 20;
          indicators.add(entry.key);
          break;
        }
      }
    }

    // Check for question patterns (showing interest)
    if (text.contains('?') && (lowerText.contains('you') || lowerText.contains('your'))) {
      score += 10;
      indicators.add('Questions about you');
    }

    // Check emoji patterns
    final heartEmojis = RegExp(r'[\u{2764}\u{1F493}\u{1F495}-\u{1F49F}]').allMatches(text);
    if (heartEmojis.length > 0) {
      score += heartEmojis.length * 5;
    }

    final kissEmojis = RegExp(r'[\u{1F618}\u{1F617}\u{1F619}]').allMatches(text);
    if (kissEmojis.length > 0) {
      score += kissEmojis.length * 8;
    }

    return FlirtResult(
      score: score.clamp(0, 100),
      isFlirting: score > 30,
      indicators: indicators,
    );
  }

  /// Categorize flirt level
  static FlirtLevel getLevel(int score) {
    if (score > 70) return FlirtLevel.high;
    if (score > 40) return FlirtLevel.medium;
    return FlirtLevel.low;
  }
}

class FlirtResult {
  final int score;
  final bool isFlirting;
  final List<String> indicators;

  FlirtResult({required this.score, required this.isFlirting, required this.indicators});
}

enum FlirtLevel { low, medium, high }