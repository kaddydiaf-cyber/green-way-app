import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static final _firestore = FirebaseFirestore.instance;

  // ==================== MESSAGES ====================

  /// Stream messages for a chat (ordered by creation time)
  static Stream<QuerySnapshot> getMessages(String requestId) {
    return _firestore
        .collection('chats')
        .doc(requestId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Send a text message
  static Future<DocumentReference> sendTextMessage({
    required String requestId,
    required String text,
    required String? senderId,
    required String senderName,
  }) {
    return _firestore
        .collection('chats')
        .doc(requestId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'text',
    });
  }

  /// Send an image message
  static Future<DocumentReference> sendImageMessage({
    required String requestId,
    required String imageUrl,
    required String? senderId,
    required String senderName,
  }) {
    return _firestore
        .collection('chats')
        .doc(requestId)
        .collection('messages')
        .add({
      'text': '',
      'imageUrl': imageUrl,
      'senderId': senderId,
      'senderName': senderName,
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'image',
    });
  }

  // ==================== BLOCKING ====================

  /// Check if current user blocked the other user
  static Future<bool> isUserBlocked({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(otherUserId)
        .get();
    return doc.exists;
  }

  /// Check if current user is blocked by the other user
  static Future<bool> isBlockedByUser({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(otherUserId)
        .collection('blockedUsers')
        .doc(currentUserId)
        .get();
    return doc.exists;
  }

  /// Block a user
  static Future<void> blockUser({
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
  }) {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(otherUserId)
        .set({
      'blockedAt': FieldValue.serverTimestamp(),
      'blockedUserName': otherUserName,
      'blockedUserId': otherUserId,
    });
  }

  /// Unblock a user
  static Future<void> unblockUser({
    required String currentUserId,
    required String otherUserId,
  }) {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(otherUserId)
        .delete();
  }

  // ==================== REPORTS ====================

  /// Submit a user report
  static Future<DocumentReference> reportUser({
    required String reporterId,
    required String reporterName,
    required String reportedUserId,
    required String reportedUserName,
    required String reason,
    required String details,
    required String chatId,
  }) {
    return _firestore.collection('reports').add({
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reportedUserId': reportedUserId,
      'reportedUserName': reportedUserName,
      'reason': reason,
      'details': details,
      'chatId': chatId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
