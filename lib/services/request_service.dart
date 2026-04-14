import 'package:cloud_firestore/cloud_firestore.dart';

class RequestService {
  static final _firestore = FirebaseFirestore.instance;
  static final _collection = _firestore.collection('requests');

  // ==================== STREAMS ====================

  /// Stream all requests for a specific user (with optional limit)
  static Stream<QuerySnapshot> getUserRequests(String userId, {int? limit}) {
    Query query = _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }

  /// Stream all requests for a user (no ordering, for counts)
  static Stream<QuerySnapshot> getUserRequestsForCount(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  /// Stream accepted requests for a user (for unread message badge)
  static Stream<QuerySnapshot> getUserAcceptedRequests(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }

  /// Stream pending requests in a specific wilaya (for collectors)
  static Stream<QuerySnapshot> getPendingRequestsByWilaya(String wilaya, {int? limit}) {
    Query query = _collection
        .where('status', isEqualTo: 'pending')
        .where('wilaya', isEqualTo: wilaya);
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }

  /// Stream collector's accepted/completed requests
  static Stream<QuerySnapshot> getCollectorRequests(String collectorId, {int? limit}) {
    Query query = _collection
        .where('collectorId', isEqualTo: collectorId)
        .where('status', whereIn: ['accepted', 'completed']);
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }

  /// Stream requests by status (for admin dashboard)
  static Stream<QuerySnapshot> getRequestsByStatus(String status) {
    return _collection
        .where('status', isEqualTo: status)
        .snapshots();
  }

  /// Stream completed requests (for factory)
  static Stream<QuerySnapshot> getCompletedRequests({int? limit}) {
    Query query = _collection
        .where('status', isEqualTo: 'completed');
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }

  /// Stream sold requests (for factory purchases history)
  static Stream<QuerySnapshot> getSoldRequests({int? limit}) {
    Query query = _collection
        .where('status', isEqualTo: 'sold');
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }

  // ==================== READS ====================

  /// Get a single request document
  static Future<DocumentSnapshot> getRequest(String requestId) {
    return _collection.doc(requestId).get();
  }

  // ==================== WRITES ====================

  /// Create a new waste collection request
  static Future<DocumentReference> createRequest({
    required String? userId,
    required String? userName,
    required String? wasteType,
    required double quantity,
    required String address,
    required String description,
    required String? wilaya,
    required String? wilayaName,
  }) {
    return _collection.add({
      'userId': userId,
      'userName': userName,
      'wasteType': wasteType,
      'quantity': quantity,
      'address': address,
      'description': description,
      'wilaya': wilaya,
      'wilayaName': wilayaName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 10));
  }

  // ==================== UPDATES ====================

  /// Cancel a request (by citizen)
  static Future<void> cancelRequest(String docId) {
    return _collection.doc(docId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancelledBy': 'citizen',
    });
  }

  /// Reopen a cancelled request
  static Future<void> reopenRequest(String docId) {
    return _collection.doc(docId).update({
      'status': 'pending',
      'collectorId': FieldValue.delete(),
      'collectorName': FieldValue.delete(),
      'acceptedAt': FieldValue.delete(),
      'reopenedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Accept a request (by collector)
  static Future<void> acceptRequest({
    required String docId,
    required String collectorId,
    required String collectorName,
  }) {
    return _collection.doc(docId).update({
      'status': 'accepted',
      'collectorId': collectorId,
      'collectorName': collectorName,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark request as completed
  static Future<void> completeRequest(String docId) {
    return _collection.doc(docId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Undo acceptance (return to pending)
  static Future<void> undoAcceptance(String docId) {
    return _collection.doc(docId).update({
      'status': 'pending',
      'collectorId': FieldValue.delete(),
      'collectorName': FieldValue.delete(),
      'acceptedAt': FieldValue.delete(),
    });
  }

  /// Mark material as sold (by factory)
  static Future<void> markAsSold({
    required String docId,
    required double price,
  }) {
    return _collection.doc(docId).update({
      'status': 'sold',
      'soldAt': FieldValue.serverTimestamp(),
      'soldPrice': price,
    });
  }

  /// Mark request as rated
  static Future<void> markAsRated({
    required String requestId,
    required String raterType,
  }) {
    final updateField = raterType == 'citizen'
        ? 'isRatedByOwner'
        : 'isRatedByCollector';

    return _collection.doc(requestId).update({
      updateField: true,
      'isRated': true,
    });
  }

  // ==================== MESSAGE FLAGS ====================

  /// Mark messages as read for the current user
  static Future<void> markMessagesAsRead({
    required String requestId,
    required bool isCollector,
  }) {
    return _collection.doc(requestId).update({
      if (isCollector) 'hasNewMessageForCollector': false,
      if (!isCollector) 'hasNewMessageForCitizen': false,
    });
  }

  /// Set new message flag for the other user
  static Future<void> setNewMessageFlag({
    required String requestId,
    required bool senderIsCollector,
  }) {
    return _collection.doc(requestId).update({
      if (senderIsCollector) 'hasNewMessageForCitizen': true,
      if (!senderIsCollector) 'hasNewMessageForCollector': true,
    });
  }
}
