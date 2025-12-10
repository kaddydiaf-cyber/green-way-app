import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:green_way_new/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // تفعيل الإشعارات
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: GreenWayApp(),
    ),
  );
}