/// Chat parser to extract conversation structure from OCR text
class ChatParser {
  ChatParser._();

  /// Parse chat text into structured messages
  static ChatData parse(String rawText) {
    final lines = rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final messages = <ChatMessage>[];

    String? currentSender;

    for (final line in lines) {
      // 1. Detect if the line is a timestamp or a header (often noise)
      if (_isTimestamp(line)) continue;

      // 2. Detect a new sender
      // Patterns: "Name:", "Name 10:00 AM", etc.
      final senderMatch = RegExp(r'^([A-Z][a-z]+(?:\s[A-Z][a-z]+)*)(?=:|\s\d{1,2}:\d{2})').firstMatch(line);

      if (senderMatch != null) {
        currentSender = senderMatch.group(1);
        // If the line contains both sender and message, extract the message part
        final messagePart = line.substring(senderMatch.end).trim();
        if (messagePart.isNotEmpty && messagePart != ':') {
          messages.add(ChatMessage(
            sender: currentSender!,
            text: messagePart,
            timestamp: DateTime.now(),
          ));
        }
      } else {
        // 3. It's a continuation of the previous message or a message without a clear sender
        if (currentSender != null) {
          // Combine with previous message if it's just a line break
          if (messages.isNotEmpty) {
            final lastMsg = messages.last;
            messages[messages.length - 1] = ChatMessage(
              sender: lastMsg.sender,
              text: '${lastMsg.text}\n$line',
              timestamp: lastMsg.timestamp,
              isFromUser: lastMsg.isFromUser,
            );
          } else {
            messages.add(ChatMessage(
              sender: currentSender,
              text: line,
              timestamp: DateTime.now(),
            ));
          }
        } else {
          // Fallback for messages where no sender was detected yet
          messages.add(ChatMessage(
            sender: 'Unknown',
            text: line,
            timestamp: DateTime.now(),
          ));
        }
      }
    }

    return ChatData(
      messages: messages,
      participants: messages.map((m) => m.sender).toSet().toList(),
    );
  }

  static bool _isTimestamp(String line) {
    // Matches 10:00 AM, 22:15, 12/05/2024, etc.
    final timestampRegex = RegExp(r'^(\d{1,2}:\d{2}\s?(?:AM|PM)?)$|^(\d{1,2}/\d{1,2}/\d{2,4})$');
    return timestampRegex.hasMatch(line);
  }

  /// Extract latest message for AI processing
  static String? extractLatestMessage(String text) {
    final data = parse(text);
    if (data.messages.isEmpty) return null;
    return data.messages.last.text;
  }
}

class ChatData {
  final List<ChatMessage> messages;
  final List<String> participants;

  ChatData({required this.messages, required this.participants});
}

class ChatMessage {
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool isFromUser;

  ChatMessage({required this.sender, required this.text, required this.timestamp, this.isFromUser = false});
}
