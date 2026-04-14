import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionPointService {
  static final _firestore = FirebaseFirestore.instance;
  static final _collection = _firestore.collection('collectionPoints');

  // ==================== STREAMS ====================

  /// Stream collection points, optionally filtered by wilaya
  static Stream<QuerySnapshot> getCollectionPoints({String? wilaya}) {
    Query query = _collection;
    if (wilaya != null) {
      query = query.where('wilaya', isEqualTo: wilaya);
    }
    return query.snapshots();
  }

  /// Stream pending collection points (for admin)
  static Stream<QuerySnapshot> getPendingPoints() {
    return _collection
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Stream collection points by status (for admin)
  static Stream<QuerySnapshot> getPointsByStatus(String status) {
    return _collection
        .where('status', isEqualTo: status)
        .snapshots();
  }

  // ==================== READS ====================

  /// Get a single collection point document
  static Future<DocumentSnapshot> getCollectionPoint(String uid) {
    return _collection.doc(uid).get();
  }

  // ==================== WRITES ====================

  /// Create a new collection point (during registration)
  static Future<void> createCollectionPoint({
    required String uid,
    required String ownerName,
    required String email,
    required String phone,
    required String wilaya,
    required String address,
    required double latitude,
    required double longitude,
    String workingHours = '08:00 - 18:00',
  }) {
    return _collection.doc(uid).set({
      'uid': uid,
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'wilaya': wilaya,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'workingHours': workingHours,
      'prices': {
        'plastic': 0,
        'paper': 0,
        'glass': 0,
        'metal': 0,
        'electronics': 0,
      },
      'status': 'pending',
      'rating': 0.0,
      'totalRatings': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  // ==================== UPDATES ====================

  /// Update materials list
  static Future<void> updateMaterials({
    required String uid,
    required List<Map<String, dynamic>> materials,
  }) {
    return _collection.doc(uid).update({
      'materials': materials,
    });
  }

  /// Approve a collection point (admin)
  static Future<void> approvePoint(String docId) {
    return _collection.doc(docId).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reject a collection point (admin)
  static Future<void> rejectPoint(String docId) {
    return _collection.doc(docId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }
}
