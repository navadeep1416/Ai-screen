import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../ocr/chat_parser.dart';
import '../ocr/ocr_pipeline.dart';

/// Chat Provider for conversation state management
class ChatProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OcrPipeline _ocrPipeline = OcrPipeline();

  List<ChatMessage> _messages = [];
  String _currentOcrText = '';
  ChatData? _chatData;
  bool _isLoading = false;
  Timer? _loopTimer;
  bool _isLooping = false;

  List<ChatMessage> get messages => _messages;
  String get currentOcrText => _currentOcrText;
  ChatData? get chatData => _chatData;
  bool get isLoading => _isLoading;
  bool get isLooping => _isLooping;

  /// Start the continuous OCR capture and AI processing loop
  void startRealTimeLoop({Duration interval = const Duration(seconds: 3)}) {
    if (_isLooping) return;
    _isLooping = true;
    _ocrPipeline.reset();
    debugPrint('[ChatProvider] Real-time AI Loop STARTED with interval: ${interval.inSeconds}s');
    notifyListeners();

    _loopTimer = Timer.periodic(interval, (timer) async {
      debugPrint('[ChatProvider] --- Timer Tick: OCR Scan Triggered ---');
      final newChatData = await _ocrPipeline.processScreen();
      
      if (newChatData != null) {
        debugPrint('[ChatProvider] New ChatData received. Updating state with ${newChatData.messages.length} messages.');
        _chatData = newChatData;
        _messages = _chatData!.messages;
        notifyListeners();
        // Here we could trigger AI analysis if needed, handled by UI or listeners
      } else {
        debugPrint('[ChatProvider] No new ChatData or identical to previous context.');
      }
    });
  }

  /// Stop the real-time loop
  void stopRealTimeLoop() {
    debugPrint('[ChatProvider] Real-time AI Loop STOPPED.');
    _loopTimer?.cancel();
    _loopTimer = null;
    _isLooping = false;
    notifyListeners();
  }

  /// Update OCR text and parse manually
  void updateOcrText(String text) {
    _currentOcrText = text;
    _chatData = ChatParser.parse(text);
    _messages = _chatData!.messages;
    notifyListeners();
  }

  /// Get sessions stream
  Stream<List<Map<String, dynamic>>> watchSessions() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Save selected reply
  Future<void> saveSelectedReply(String sessionId, String reply) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(sessionId)
        .update({'selectedReply': reply});
  }

  /// Clear chat
  void clear() {
    _messages = [];
    _currentOcrText = '';
    _chatData = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopRealTimeLoop();
    super.dispose();
  }
}

