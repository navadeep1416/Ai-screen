/// Mood detection service
class MoodDetector {
  MoodDetector._();

  /// Detect emotions from text
  static List<String> detectMood(String text) {
    final emotions = <String>[];
    final lowerText = text.toLowerCase();

    // Emotion keywords
    final emotionMap = {
      'Happy': ['happy', 'great', 'awesome', 'amazing', 'love', '😊', '😄'],
      'Sad': ['sad', 'upset', 'miss', 'sorry', '😢', '😔'],
      'Angry': ['angry', 'mad', 'hate', 'annoyed', '😠', '😡'],
      'Excited': ['excited', 'can\'t wait', 'omg', 'wow', '🎉'],
      'Flirty': ['❤️', '💖', '💕', 'miss you', 'think about', 'cute'],
      'Playful': ['lol', 'haha', '😂', 'funny', 'joking', '😏'],
      'Curious': ['what', 'why', 'how', 'really', 'tell me'],
    };

    for (final entry in emotionMap.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          emotions.add(entry.key);
          break;
        }
      }
    }

    // Default to neutral if no emotions detected
    if (emotions.isEmpty) emotions.add('Neutral');

    return emotions;
  }

  /// Calculate mood intensity (0-100)
  static int calculateIntensity(String text) {
    final lowerText = text.toLowerCase();
    int score = 50; // Base neutral

    // Increase intensity with exclamation marks
    score += text.split('!').length * 5;

    // Increase with all caps words
    final capsWords = RegExp(r'\b[A-Z]{2,}\b').allMatches(text);
    score += capsWords.length * 3;

    // Increase with emoji density
    final emojis = RegExp(r'[\u{1F300}-\u{1F9FF}]').allMatches(text);
    score += emojis.length * 4;

    return score.clamp(0, 100);
  }

  /// Detect mood changes over conversation
  static List<String> detectMoodChanges(List<String> messages) {
    if (messages.length < 2) return [];

    final changes = <String>[];
    String? previousMood;

    for (final msg in messages) {
      final currentMood = detectMood(msg).first;
      if (previousMood != null && previousMood != currentMood) {
        changes.add('$previousMood → $currentMood');
      }
      previousMood = currentMood;
    }

    return changes;
  }
}