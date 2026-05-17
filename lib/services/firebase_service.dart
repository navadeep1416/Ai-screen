import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication Methods
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Firestore Methods
  Future<void> saveChatHistory({
    required String uid,
    required String chatText,
    required String generatedReply,
    required String mode,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('history')
          .add({
        'chatText': chatText,
        'generatedReply': generatedReply,
        'mode': mode,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  Stream<QuerySnapshot> getChatHistoryStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> logAnalyticsEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    try {
      // Typically use FirebaseAnalytics here. Since firebase_analytics isn't in pubspec,
      // we log to a special firestore collection or just print for now.
      debugPrint('Analytics Event: $eventName, Parameters: $parameters');
      if (currentUser != null) {
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('analytics_events')
            .add({
          'eventName': eventName,
          'parameters': parameters ?? {},
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error logging event: $e');
    }
  }
}
