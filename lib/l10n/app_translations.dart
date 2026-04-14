import 'package:green_way_new/l10n/translations_ar.dart';
import 'package:green_way_new/l10n/translations_fr.dart';
import 'package:green_way_new/l10n/translations_en.dart';

class AppTranslations {
  static Map<String, String> get(String langCode) {
    switch (langCode) {
      case 'ar':
        return translationsAr;
      case 'fr':
        return translationsFr;
      default:
        return translationsEn;
    }
  }
}
