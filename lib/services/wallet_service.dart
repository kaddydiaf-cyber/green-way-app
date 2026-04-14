import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  static final _firestore = FirebaseFirestore.instance;

  // ==================== STREAMS ====================

  /// Stream user profile (for wallet balance)
  static Stream<DocumentSnapshot> getUserProfileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  /// Stream transaction history (last 20)
  static Stream<QuerySnapshot> getTransactionHistory(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  // ==================== OPERATIONS ====================

  /// Deposit funds (atomic: updates balance + creates transaction)
  static Future<void> deposit({
    required String userId,
    required double amount,
    required String description,
  }) async {
    final batch = _firestore.batch();

    final userRef = _firestore.collection('users').doc(userId);
    batch.update(userRef, {
      'walletBalance': FieldValue.increment(amount),
    });

    final transactionRef = _firestore.collection('transactions').doc();
    batch.set(transactionRef, {
      'userId': userId,
      'type': 'deposit',
      'amount': amount,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Withdraw funds (atomic: updates balance + creates transaction)
  static Future<void> withdraw({
    required String userId,
    required double amount,
    required String description,
  }) async {
    final batch = _firestore.batch();

    final userRef = _firestore.collection('users').doc(userId);
    batch.update(userRef, {
      'walletBalance': FieldValue.increment(-amount),
    });

    final transactionRef = _firestore.collection('transactions').doc();
    batch.set(transactionRef, {
      'userId': userId,
      'type': 'withdraw',
      'amount': amount,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
