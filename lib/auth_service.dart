import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:green_way_new/notification_service.dart';
import 'package:green_way_new/services/user_service.dart';
import 'package:green_way_new/services/collection_point_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    required String wilaya,
  }) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = result.user;

    if (user != null) {
      await user.updateDisplayName(name);

      String? fcmToken = await NotificationService.getToken();

      await UserService.createUser(
        uid: user.uid,
        email: email,
        name: name,
        phone: phone,
        role: role,
        wilaya: wilaya,
        fcmToken: fcmToken,
      );

      NotificationService.startListening();
    }

    return user;
  }

  // تسجيل نقطة جمع جديدة
  Future<User?> registerCollectionPoint({
    required String email,
    required String password,
    required String ownerName,
    required String phone,
    required String wilaya,
    required String address,
    required double latitude,
    required double longitude,
    String? workingHours,
  }) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = result.user;

    if (user != null) {
      await user.updateDisplayName(ownerName);

      String? fcmToken = await NotificationService.getToken();

      // حفظ بيانات المستخدم
      await UserService.createUser(
        uid: user.uid,
        email: email,
        name: ownerName,
        phone: phone,
        role: 'collection_point',
        wilaya: wilaya,
        fcmToken: fcmToken,
      );

      // حفظ بيانات نقطة الجمع
      await CollectionPointService.createCollectionPoint(
        uid: user.uid,
        ownerName: ownerName,
        email: email,
        phone: phone,
        wilaya: wilaya,
        address: address,
        latitude: latitude,
        longitude: longitude,
        workingHours: workingHours ?? '08:00 - 18:00',
      );

      NotificationService.startListening();
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

    if (result.user != null) {
      print('========== LOGIN UID: ${result.user!.uid} ==========');

      // تحقق أن المستند موجود قبل التحديث
      final doc = await UserService.getUser(result.user!.uid);
      print('========== DOC EXISTS: ${doc.exists} ==========');

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('========== ROLE FROM DB: ${data['role']} ==========');

        String? fcmToken = await NotificationService.getToken();
        await UserService.updateFcmToken(
          uid: result.user!.uid,
          fcmToken: fcmToken,
        );
      }

      NotificationService.startListening();
    }

    return result.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> getUserRole(String uid) async {
    try {
      return await UserService.getUserRole(uid);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserWilaya(String uid) async {
    try {
      return await UserService.getUserWilaya(uid);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserFcmToken(String uid) async {
    try {
      return await UserService.getUserFcmToken(uid);
    } catch (e) {
      return null;
    }
  }
}