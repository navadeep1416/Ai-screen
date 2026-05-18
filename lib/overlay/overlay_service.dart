import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../core/constants/app_constants.dart';
import '../ocr/ocr_pipeline.dart';
import '../ocr/chat_parser.dart';
import '../services/api_service.dart';
import '../ai/groq_service.dart';

class OverlayService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ApiService _apiService = ApiService();
  static final OcrPipeline _ocrPipeline = OcrPipeline();

  static Timer? _captureTimer;
  static String _currentMode = 'Crush';
  static bool _isWatching = false;

  /// Launch the floating overlay
  static Future<void> startOverlay() async {
    final isGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!isGranted) await FlutterOverlayWindow.requestPermission();
    if (await FlutterOverlayWindow.isActive()) return;

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: "Nava Screen AI",
      overlayContent: "Assistant Running",
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      height: AppConstants.overlayMediumHeight.toInt(),
      width: WindowSize.matchParent.toInt(),
    );
    startWatching('Crush');
  }

  /// Close and cleanup overlay
  static Future<void> closeOverlay() async {
    stopWatching();
    await FlutterOverlayWindow.closeOverlay();
  }

  /// Start the real-time OCR and AI loop
  static void startWatching(String mode) {
    _currentMode = mode;
    if (_isWatching) return;
    _isWatching = true;
    FlutterOverlayWindow.shareData({"status": "watching", "mode": mode});

    _captureTimer = Timer.periodic(
      const Duration(seconds: AppConstants.screenCaptureIntervalSeconds),
      (timer) async => await _captureAndAnalyze()
    );
  }

  /// Stop the real-time loop
  static void stopWatching() {
    _isWatching = false;
    _captureTimer?.cancel();
    _captureTimer = null;
    FlutterOverlayWindow.shareData({"status": "stopped"});
  }

  /// Update active mode and trigger immediate analysis
  static void updateMode(String newMode) {
    _currentMode = newMode;
    FlutterOverlayWindow.shareData({"mode": newMode});
    if (_isWatching) _captureAndAnalyze();
  }

  /// Force a regeneration of replies for the current context
  static Future<void> regenerateReplies() async {
    // We use a temporary "dummy" update to trigger the loop or just call analysis
    if (_isWatching) {
      await _captureAndAnalyze();
    }
  }

  /// The core loop: Capture -> OCR -> Parse -> Analyze -> Update
  static Future<void> _captureAndAnalyze() async {
    try {
      // 1. OCR Pipeline process
      final chatData = await _ocrPipeline.processScreen();
      if (chatData == null || chatData.messages.isEmpty) return;

      final fullText = chatData.messages.map((m) => '${m.sender}: ${m.text}').join('\n');
      final latestMessage = chatData.messages.last.text;

      // Update overlay with current text context
      FlutterOverlayWindow.shareData({
        "event": "ocr_update",
        "text": latestMessage,
      });

      // 2. AI Analysis (using GroqService which wraps ApiService)
      await _analyzeAndSave(fullText, latestMessage);
    } catch (e) {
      print("Error in AI Loop: $e");
      FlutterOverlayWindow.shareData({"event": "error", "message": "AI Loop Error"});
    }
  }

  /// Handles the AI analysis and Firebase persistence
  static Future<void> _analyzeAndSave(String fullText, String latestMessage) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';

    try {
      FlutterOverlayWindow.shareData({"event": "analyzing"});

      // Analyze the chat for mood and metrics
      final analysisResult = await GroqService.analyzeText(fullText, _currentMode, userId);

      // Generate smart replies
      final repliesResult = await GroqService.generateReplies(fullText, _currentMode, 3);

      // Combine results into a session object
      final sessionData = {
        'timestamp': FieldValue.serverTimestamp(),
        'appDetected': 'Detected App', // In production, use package manager to detect app
        'mode': _currentMode,
        'ocrText': fullText,
        'analysis': analysisResult['analysis'] ?? analysisResult,
        'replies': repliesResult['replies'] ?? repliesResult,
      };

      // Save to Firestore
      final docRef = _firestore.collection('users').doc(userId).collection('sessions').doc();
      await docRef.set(sessionData);

      // Update user stats
      await _firestore.collection('users').doc(userId).set({
        'totalSessions': FieldValue.increment(1),
        'totalReplies': FieldValue.increment((repliesResult['replies'] as List?)?.length ?? 0),
      }, SetOptions(merge: true));

      // Update the Floating Popup UI
      FlutterOverlayWindow.shareData({
        "event": "analysis_complete",
        "sessionId": docRef.id,
        "data": sessionData
      });
    } catch (e) {
      print("Error analyzing with Groq: $e");
      FlutterOverlayWindow.shareData({"event": "error", "message": "Analysis Failed"});
    }
  }

  /// Select and save the chosen reply
  static Future<void> selectReply(String sessionId, String replyStyle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('sessions').doc(sessionId).update({
        'selectedReply': replyStyle,
        'selectedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
