import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static final _firestore = FirebaseFirestore.instance;
  static final _collection = _firestore.collection('users');

  // ==================== STREAMS ====================

  /// Stream user profile data
  static Stream<DocumentSnapshot> getUserStream(String userId) {
    return _collection.doc(userId).snapshots();
  }

  /// Stream users by role (for admin)
  static Stream<QuerySnapshot> getUsersByRole(String role) {
    return _collection
        .where('role', isEqualTo: role)
        .snapshots();
  }

  /// Stream all users (for admin management)
  static Stream<QuerySnapshot> getAllUsers() {
    return _collection.snapshots();
  }

  // ==================== READS ====================

  /// Get user document
  static Future<DocumentSnapshot> getUser(String uid) {
    return _collection.doc(uid).get();
  }

  /// Get user role
  static Future<String?> getUserRole(String uid) async {
    final doc = await _collection.doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['role'] as String?;
    }
    return null;
  }

  /// Get user wilaya
  static Future<String?> getUserWilaya(String uid) async {
    final doc = await _collection.doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['wilaya'] as String?;
    }
    return null;
  }

  /// Get user FCM token
  static Future<String?> getUserFcmToken(String uid) async {
    final doc = await _collection.doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['fcmToken'] as String?;
    }
    return null;
  }

  // ==================== WRITES ====================

  /// Create user profile (during registration)
  static Future<void> createUser({
    required String uid,
    required String email,
    required String name,
    required String phone,
    required String role,
    required String wilaya,
    String? fcmToken,
  }) {
    return _collection.doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'wilaya': wilaya,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'walletBalance': 0.0,
      'fcmToken': fcmToken,
    });
  }

  // ==================== UPDATES ====================

  /// Update FCM token
  static Future<void> updateFcmToken({
    required String uid,
    required String? fcmToken,
  }) {
    return _collection.doc(uid).update({
      'fcmToken': fcmToken,
    });
  }

  /// Update user rating stats
  static Future<void> updateRatingStats({
    required String userId,
    required double averageRating,
    required int totalRatings,
    required bool isTrusted,
  }) {
    return _collection.doc(userId).update({
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'isTrusted': isTrusted,
    });
  }
}
