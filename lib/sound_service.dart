import 'package:flutter/services.dart';

class SoundService {
  // صوت إشعار جديد (طلب جديد)
  static Future<void> playNotificationSound() async {
    try {
      // اهتزاز متوسط
      await HapticFeedback.mediumImpact();
      // صوت تنبيه النظام
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  // صوت نجاح (قبول الطلب / إتمام)
  static Future<void> playSuccessSound() async {
    try {
      // اهتزاز خفيف
      await HapticFeedback.lightImpact();
      // صوت نقرة
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('Error playing success sound: $e');
    }
  }

  // اهتزاز فقط (للتنبيهات الصامتة)
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      print('Error vibrating: $e');
    }
  }
}