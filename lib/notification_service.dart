import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/sound_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // طلب إذن الإشعارات
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // إعداد الإشعارات المحلية
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // استقبال الإشعارات عندما التطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(
        title: message.notification?.title ?? 'Green Way',
        body: message.notification?.body ?? '',
      );
    });

    // بدء الاستماع للإشعارات من Firestore
    _listenToNotifications();

    // الحصول على Token الجهاز
    try {
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
    } catch (e) {
      print('FCM getToken failed: $e');
    }
  }

  // الاستماع للإشعارات الجديدة من Firestore
  static void _listenToNotifications() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection('notifications')
        .where('receiverUserId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            // تشغيل صوت الإشعار
            SoundService.playNotificationSound();

            // عرض الإشعار
            _showLocalNotification(
              title: data['title'] ?? 'Green Way',
              body: data['body'] ?? '',
            );

            // تحديد الإشعار كمقروء
            change.doc.reference.update({'isRead': true});
          }
        }
      }
    });
  }

  // إعادة تشغيل المستمع عند تسجيل الدخول
  static void startListening() {
    _listenToNotifications();
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'green_way_channel',
      'Green Way Notifications',
      channelDescription: 'إشعارات تطبيق Green Way',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  // إرسال إشعار محلي (للجهاز الحالي فقط)
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await _showLocalNotification(title: title, body: body);
  }

  // إرسال إشعار لمستخدم معين عبر Firestore
  static Future<void> sendNotificationToUser({
    required String receiverUserId,
    required String title,
    required String body,
    String? chatId,
  }) async {
    try {
      // حفظ الإشعار في Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'receiverUserId': receiverUserId,
        'title': title,
        'body': body,
        'chatId': chatId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // الحصول على Token الجهاز لحفظه في قاعدة البيانات
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('FCM getToken failed: $e');
      return null;
    }
  }
}