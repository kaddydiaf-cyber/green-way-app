import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/l10n/app_translations.dart';

class TimeUtils {
  static String getTimeAgo(Timestamp? timestamp, {String langCode = 'ar'}) {
    if (timestamp == null) return '';

    final t = AppTranslations.get(langCode);
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return t['now']!;
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      if (minutes == 1) return t['minute_singular']!;
      if (minutes == 2) return t['minutes_two']!;
      if (minutes <= 10) return '$minutes ${t['minutes_plural']!}';
      return '$minutes ${t['minute_singular']!}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      if (hours == 1) return t['hour_singular']!;
      if (hours == 2) return t['hours_two']!;
      if (hours <= 10) return '$hours ${t['hours_plural']!}';
      return '$hours ${t['hour_singular']!}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) return t['day_singular']!;
      if (days == 2) return t['days_two']!;
      if (days <= 10) return '$days ${t['days_plural']!}';
      return '$days ${t['day_singular']!}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static String getFormattedDateTime(Timestamp? timestamp, {String langCode = 'ar'}) {
    if (timestamp == null) return '';

    final t = AppTranslations.get(langCode);
    final date = timestamp.toDate();
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? t['pm']! : t['am']!;
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.day}/${date.month}/${date.year} - $hour:$minute $period';
  }
}
