import 'package:flutter_test/flutter_test.dart';
import 'package:green_way_new/l10n/app_translations.dart';
import 'package:green_way_new/l10n/translations_ar.dart';
import 'package:green_way_new/l10n/translations_en.dart';
import 'package:green_way_new/l10n/translations_fr.dart';

void main() {
  group('AppTranslations', () {
    test('returns Arabic translations for "ar"', () {
      final t = AppTranslations.get('ar');
      expect(t, equals(translationsAr));
    });

    test('returns French translations for "fr"', () {
      final t = AppTranslations.get('fr');
      expect(t, equals(translationsFr));
    });

    test('returns English translations for "en"', () {
      final t = AppTranslations.get('en');
      expect(t, equals(translationsEn));
    });

    test('returns English as default for unknown language', () {
      final t = AppTranslations.get('de');
      expect(t, equals(translationsEn));
    });

    test('all languages have the same keys', () {
      final arKeys = translationsAr.keys.toSet();
      final frKeys = translationsFr.keys.toSet();
      final enKeys = translationsEn.keys.toSet();

      // Keys in Arabic but missing from French
      final missingInFr = arKeys.difference(frKeys);
      expect(missingInFr, isEmpty, reason: 'Keys missing in French: $missingInFr');

      // Keys in Arabic but missing from English
      final missingInEn = arKeys.difference(enKeys);
      expect(missingInEn, isEmpty, reason: 'Keys missing in English: $missingInEn');

      // Keys in English but missing from Arabic
      final missingInAr = enKeys.difference(arKeys);
      expect(missingInAr, isEmpty, reason: 'Keys missing in Arabic: $missingInAr');
    });

    test('no translation value is empty', () {
      for (final entry in translationsAr.entries) {
        expect(entry.value.isNotEmpty, isTrue,
            reason: 'Arabic key "${entry.key}" has empty value');
      }
      for (final entry in translationsFr.entries) {
        expect(entry.value.isNotEmpty, isTrue,
            reason: 'French key "${entry.key}" has empty value');
      }
      for (final entry in translationsEn.entries) {
        expect(entry.value.isNotEmpty, isTrue,
            reason: 'English key "${entry.key}" has empty value');
      }
    });

    test('essential keys exist in all languages', () {
      final essentialKeys = [
        'app_name',
        'cancel',
        'save',
        'delete',
        'send',
        'error',
        'success',
        'loading',
        'welcome_subtitle',
        'welcome_start',
      ];

      for (final key in essentialKeys) {
        expect(translationsAr.containsKey(key), isTrue,
            reason: 'Arabic missing key: $key');
        expect(translationsFr.containsKey(key), isTrue,
            reason: 'French missing key: $key');
        expect(translationsEn.containsKey(key), isTrue,
            reason: 'English missing key: $key');
      }
    });
  });
}
