import '../core/constants/app_constants.dart';

/// Mode engine for relationship mode management
class ModeEngine {
  ModeEngine._();

  /// Get mode emoji
  static String getEmoji(RelationshipMode mode) => mode.emoji;

  /// Get mode vibe
  static String getVibe(RelationshipMode mode) => mode.vibe;

  /// Get mode from string
  static RelationshipMode fromString(String name) {
    return RelationshipMode.fromString(name);
  }

  /// Get all modes as list
  static List<RelationshipMode> getAllModes() {
    return RelationshipMode.values;
  }

  /// Get mode-specific prompt adjustment
  static String getModePromptAdjustment(RelationshipMode mode) {
    switch (mode) {
      case RelationshipMode.love:
        return 'Use warm, romantic language. Show deep care and emotional connection.';
      case RelationshipMode.oneSide:
        return 'Subtle hints, trying to impress, slightly hopeful but not desperate.';
      case RelationshipMode.friend:
        return 'Casual, funny, relaxed. Use humor and inside jokes when appropriate.';
      case RelationshipMode.fight:
        return 'De-escalating, calm, firm. Take a stand without being aggressive.';
      case RelationshipMode.enemy:
        return 'Savage, sharp, cold. Minimal engagement, protective tone.';
      case RelationshipMode.stranger:
        return 'Polite, curious, safe openers. Build rapport gradually.';
      case RelationshipMode.maleFriend:
        return 'Bro energy, banter, direct. Use casual language and humor.';
      case RelationshipMode.femaleFriend:
        return 'Supportive, expressive, emotional. Show understanding and empathy.';
      case RelationshipMode.crush:
        return 'Playful, flirty, mysterious. Keep them curious and interested.';
      case RelationshipMode.bestFriend:
        return 'Brutally honest, inside jokes. No filter but always supportive.';
      case RelationshipMode.bestie:
        return 'Deep comfort, no filter. Complete authenticity, inside references.';
    }
  }

  /// Get suggested reply styles for mode
  static List<ReplyStyle> getSuggestedStyles(RelationshipMode mode) {
    switch (mode) {
      case RelationshipMode.love:
        return [ReplyStyle.emotional, ReplyStyle.playful, ReplyStyle.flirty];
      case RelationshipMode.oneSide:
        return [ReplyStyle.playful, ReplyStyle.tease, ReplyStyle.flirty];
      case RelationshipMode.friend:
        return [ReplyStyle.funny, ReplyStyle.playful, ReplyStyle.tease];
      case RelationshipMode.fight:
        return [ReplyStyle.savage, ReplyStyle.playful];
      case RelationshipMode.enemy:
        return [ReplyStyle.savage, ReplyStyle.mysterious];
      case RelationshipMode.stranger:
        return [ReplyStyle.playful, ReplyStyle.mysterious];
      case RelationshipMode.maleFriend:
        return [ReplyStyle.funny, ReplyStyle.playful, ReplyStyle.tease];
      case RelationshipMode.femaleFriend:
        return [ReplyStyle.emotional, ReplyStyle.playful, ReplyStyle.flirty];
      case RelationshipMode.crush:
        return [ReplyStyle.flirty, ReplyStyle.playful, ReplyStyle.mysterious];
      case RelationshipMode.bestFriend:
        return [ReplyStyle.funny, ReplyStyle.savage, ReplyStyle.tease];
      case RelationshipMode.bestie:
        return [ReplyStyle.funny, ReplyStyle.playful, ReplyStyle.emotional];
    }
  }

  /// Calculate mode match percentage
  static int calculateMatchPercentage(String detectedMode, String selectedMode) {
    // Similar modes have higher match
    final similarModes = {
      'Friend': ['Male Friend', 'Female Friend', 'Best Friend'],
      'Love': ['Crush', 'Bestie'],
      'Crush': ['Love', 'Flirty'],
      'Best Friend': ['Bestie', 'Friend'],
    };

    if (detectedMode == selectedMode) return 90;
    if (similarModes[selectedMode]?.contains(detectedMode) ?? false) return 75;
    return 55;
  }
}