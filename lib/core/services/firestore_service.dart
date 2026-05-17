import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore service for database operations
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Get users collection reference
  static CollectionReference get usersRef => _firestore.collection('users');

  /// Get user document reference
  static DocumentReference userDoc(String userId) => usersRef.doc(userId);

  /// Get settings subcollection reference
  static CollectionReference settingsRef(String userId) =>
      userDoc(userId).collection('settings');

  /// Get sessions subcollection reference
  static CollectionReference sessionsRef(String userId) =>
      userDoc(userId).collection('sessions');

  /// Get user settings document
  static Future<Map<String, dynamic>?> getUserSettings(String userId) async {
    final doc = await _firestore.collection('settings').doc(userId).get();
    return doc.data();
  }

  /// Update user settings
  static Future<void> updateUserSettings(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('settings').doc(userId).set(
          data,
          SetOptions(merge: true),
        );
  }

  /// Save session to Firestore
  static Future<String> saveSession(
    String userId, {
    required String mode,
    required String ocrText,
    required Map<String, dynamic> analysis,
    required List<Map<String, dynamic>> replies,
  }) async {
    final docRef = sessionsRef(userId).doc();

    await docRef.set({
      'timestamp': FieldValue.serverTimestamp(),
      'mode': mode,
      'ocrText': ocrText,
      'analysis': analysis,
      'replies': replies,
    });

    // Update user stats
    await userDoc(userId).set({
      'totalSessions': FieldValue.increment(1),
      'totalReplies': FieldValue.increment(replies.length),
    }, SetOptions(merge: true));

    return docRef.id;
  }

  /// Get user sessions
  static Stream<List<Map<String, dynamic>>> watchUserSessions(String userId) {
    return sessionsRef(userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Update session with selected reply
  static Future<void> selectReply(String userId, String sessionId, String style) async {
    await sessionsRef(userId).doc(sessionId).update({
      'selectedReply': style,
    });
  }
}