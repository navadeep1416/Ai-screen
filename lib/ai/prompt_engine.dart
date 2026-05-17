import '../core/constants/app_constants.dart';

/// Prompt engineering for AI analysis
class PromptEngine {
  PromptEngine._();

  /// Build system prompt for AI context
  static String buildSystemPrompt() {
    return '''
You are Nava, an advanced AI conversation assistant.
You analyze chat conversations and generate intelligent, context-aware replies.
Your goal is to help users communicate better while maintaining authenticity.

Core principles:
- Analyze mood, intent, and relationship dynamics
- Generate replies that match the selected relationship mode
- Consider conversation flow and emotional context
- Provide insights that help users understand the other person

Relationship modes:
${RelationshipMode.values.map((m) => '- ${m.name}: ${m.vibe}').join('\n')}

Reply styles:
${ReplyStyle.values.map((s) => '- ${s.label}').join('\n')}
''';
  }

  /// Build analysis prompt for text
  static String buildAnalysisPrompt({
    required String text,
    required String mode,
    String? context,
  }) {
    return '''
Analyze the following chat conversation and provide detailed insights.

${
  context != null
    ? 'Context: $context\n'
    : ''
}
Current relationship mode: $mode

Chat text:
$text

Provide analysis including:
1. Detected emotions and mood
2. Interest level indicator
3. Conversation energy
4. Key insights about the other person
5. Recommended reply strategy
''';
  }

  /// Build reply generation prompt
  static String buildReplyPrompt({
    required String text,
    required String mode,
    required ReplyStyle style,
    int count = 3,
  }) {
    return '''
Generate $count distinct reply options for this conversation.

Mode: $mode
Style: ${style.label}

Chat:
$text

Generate replies that:
- Match the $mode relationship dynamic
- Use ${style.label} tone
- Are natural and authentic
- Vary in approach while staying consistent
''';
  }

  /// Build follow-up prompt for additional analysis
  static String buildFollowUpPrompt({
    required String originalText,
    required String previousReply,
    required String mode,
    required String feedback,
  }) {
    return '''
The user sent this reply: "$previousReply"
The other person's response: "$originalText"

Feedback: $feedback
Mode: $mode

Analyze this interaction and provide:
1. How well the reply worked
2. Suggested adjustments
3. Next response recommendations
''';
  }

  /// Extract JSON from AI response
  static String? extractJson(String response) {
    // Try to find JSON in the response
    final jsonPattern = RegExp(r'\{[\s\S]*\}|\[[\s\S]*\]');
    final match = jsonPattern.firstMatch(response);
    return match?.group(0);
  }

  /// Sanitize prompt input
  static String sanitize(String input) {
    // Remove potential injection patterns
    return input
        .replaceAll(RegExp(r'\{|\}'), '')
        .replaceAll(RegExp(r'\[|\]'), '')
        .replaceAll(RegExp(r'<|>'), '')
        .trim();
  }
}