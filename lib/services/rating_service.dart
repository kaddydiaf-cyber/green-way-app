import 'package:cloud_firestore/cloud_firestore.dart';

class RatingService {
  static final _firestore = FirebaseFirestore.instance;
  static final _collection = _firestore.collection('ratings');

  // ==================== STREAMS ====================

  /// Stream recent ratings for a user (limited)
  static Stream<QuerySnapshot> getRecentRatings(String userId, {int limit = 3}) {
    return _collection
        .where('ratedUserId', isEqualTo: userId)
        .limit(limit)
        .snapshots();
  }

  /// Stream all ratings for a user
  static Stream<QuerySnapshot> getAllRatings(String userId) {
    return _collection
        .where('ratedUserId', isEqualTo: userId)
        .snapshots();
  }

  // ==================== OPERATIONS ====================

  /// Submit a new rating
  static Future<DocumentReference> submitRating({
    required String requestId,
    required String? raterId,
    required String raterName,
    required String raterType,
    required String ratedUserId,
    required String ratedUserName,
    required int rating,
    required String comment,
  }) {
    return _collection.add({
      'requestId': requestId,
      'raterId': raterId,
      'raterName': raterName,
      'raterType': raterType,
      'ratedUserId': ratedUserId,
      'ratedUserName': ratedUserName,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Calculate and update user's average rating
  static Future<void> updateUserRating(String ratedUserId) async {
    final ratings = await _collection
        .where('ratedUserId', isEqualTo: ratedUserId)
        .get();

    if (ratings.docs.isNotEmpty) {
      double totalRating = 0;
      for (var doc in ratings.docs) {
        totalRating += (doc.data()['rating'] ?? 0).toDouble();
      }
      final averageRating = totalRating / ratings.docs.length;
      final totalCount = ratings.docs.length;
      final isTrusted = averageRating >= 4.0 && totalCount >= 5;

      await _firestore.collection('users').doc(ratedUserId).update({
        'averageRating': averageRating,
        'totalRatings': totalCount,
        'isTrusted': isTrusted,
      });
    }
  }
}
