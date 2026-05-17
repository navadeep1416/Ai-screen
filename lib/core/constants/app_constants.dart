/// App-wide constants for Nava Screen AI
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Nava Screen AI';
  static const String appVersion = '2.4.1';
  static const String tagline = 'thinks like a friend, replies like you';
  static const String developer = 'Navadeep';
  static const String location = 'Hyderabad, India';

  // API Endpoints
  static const String baseUrl = 'https://nava-screen-ai-production.up.railway.app/api';
  static const String analyzeEndpoint = '/analyze';
  static const String visionEndpoint = '/vision';

  // Timing
  static const int screenCaptureIntervalSeconds = 3;
  static const int animationDurationMs = 300;
  static const int splashDurationMs = 2000;

  // Overlay Sizes
  static const double overlayMinHeight = 100;
  static const double overlaySmallHeight = 300;
  static const double overlayMediumHeight = 500;
  static const double overlayLargeHeight = 800;

  // Storage Keys
  static const String keyFirstLaunch = 'firstLaunch';
  static const String keyOnboardingComplete = 'onboardingComplete';
  static const String keyDefaultMode = 'defaultMode';
  static const String keyPopupSize = 'popupSize';
  static const String keyAccentColor = 'accentColor';
}

/// Relationship modes with emojis and vibes
enum RelationshipMode {
  love('❤️', 'Warm, romantic, deeply engaged'),
  oneSide('🥺', 'Subtle hints, trying to impress'),
  friend('😂', 'Casual, funny, relaxed'),
  fight('⚔️', 'De-escalating, calm, firm'),
  enemy('😤', 'Savage, sharp, cold'),
  stranger('👋', 'Polite, curious, safe openers'),
  maleFriend('🤜', 'Bro energy, banter, direct'),
  femaleFriend('💅', 'Supportive, expressive, emotional'),
  crush('💖', 'Playful, flirty, mysterious'),
  bestFriend('🔥', 'Brutally honest, inside jokes'),
  bestie('👑', 'Deep comfort, no filter');

  final String emoji;
  final String vibe;

  const RelationshipMode(this.emoji, this.vibe);

  static RelationshipMode fromString(String name) {
    return RelationshipMode.values.firstWhere(
      (mode) => mode.name.toLowerCase() == name.toLowerCase().replaceAll(' ', '').replaceAll('frnd', 'friend'),
      orElse: () => RelationshipMode.friend,
    );
  }
}

/// AI reply styles
enum ReplyStyle {
  funny('Funny'),
  flirty('Flirty'),
  emotional('Emotional'),
  savage('Savage'),
  mysterious('Mysterious'),
  playful('Playful'),
  tease('Tease');

  final String label;

  const ReplyStyle(this.label);
}

/// Popup size modes
enum PopupSizeMode {
  minimised,
  small,
  medium,
  large;

  double get height {
    switch (this) {
      case PopupSizeMode.minimised:
        return AppConstants.overlayMinHeight;
      case PopupSizeMode.small:
        return AppConstants.overlaySmallHeight;
      case PopupSizeMode.medium:
        return AppConstants.overlayMediumHeight;
      case PopupSizeMode.large:
        return AppConstants.overlayLargeHeight;
    }
  }
}