import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = result.user;

    if (user != null) {
      await user.updateDisplayName(name);

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'phone': phone,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'walletBalance': 0.0,
      });
    }

    return user;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}