import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_way_new/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('primary colors are defined', () {
      expect(AppColors.primary, equals(const Color(0xFF4CAF50)));
      expect(AppColors.primaryDark, equals(const Color(0xFF2E7D32)));
      expect(AppColors.primaryLight, equals(const Color(0xFFC8E6C9)));
    });

    test('semantic colors are defined', () {
      expect(AppColors.error, equals(Colors.red));
      expect(AppColors.warning, equals(Colors.orange));
      expect(AppColors.info, equals(Colors.blue));
      expect(AppColors.success, equals(Colors.green));
    });

    test('status colors are defined', () {
      expect(AppColors.statusPending, equals(Colors.orange));
      expect(AppColors.statusAccepted, equals(Colors.blue));
      expect(AppColors.statusCompleted, equals(Colors.green));
      expect(AppColors.statusCancelled, equals(Colors.red));
      expect(AppColors.statusSold, equals(Colors.teal));
    });

    test('role colors are defined', () {
      expect(AppColors.roleCitizen, equals(Colors.blue));
      expect(AppColors.roleCollector, equals(Colors.purple));
      expect(AppColors.roleCollectionPoint, equals(Colors.orange));
      expect(AppColors.roleFactory, equals(Colors.teal));
      expect(AppColors.roleAdmin, equals(Colors.red));
    });

    test('waste type colors are defined', () {
      expect(AppColors.wastePlastic, equals(Colors.blue));
      expect(AppColors.wastePaper, equals(Colors.brown));
      expect(AppColors.wasteGlass, equals(Colors.green));
      expect(AppColors.wasteMetal, equals(Colors.grey));
      expect(AppColors.wasteElectronics, equals(Colors.purple));
      expect(AppColors.wasteOrganic, equals(Colors.lightGreen));
    });

    test('light theme colors are defined', () {
      expect(AppColors.backgroundLight, equals(const Color(0xFFF5F5F5)));
      expect(AppColors.surfaceLight, equals(Colors.white));
      expect(AppColors.onSurfaceLight, equals(const Color(0xFF212121)));
      expect(AppColors.subtextLight, equals(const Color(0xFF757575)));
    });

    test('dark theme colors are defined', () {
      expect(AppColors.backgroundDark, equals(const Color(0xFF121212)));
      expect(AppColors.surfaceDark, equals(const Color(0xFF1E1E1E)));
      expect(AppColors.cardDark, equals(const Color(0xFF2C2C2C)));
      expect(AppColors.onSurfaceDark, equals(const Color(0xFFE0E0E0)));
      expect(AppColors.subtextDark, equals(const Color(0xFFB0B0B0)));
    });

    test('primaryTint returns color with correct alpha', () {
      final tint = AppColors.primaryTint(50);
      expect(tint.a, closeTo(50 / 255, 0.01));
    });

    test('primaryTint default alpha is 30', () {
      final tint = AppColors.primaryTint();
      expect(tint.a, closeTo(30 / 255, 0.01));
    });

    test('cardShadow returns a list of BoxShadow', () {
      final shadows = AppColors.cardShadow;
      expect(shadows, isNotEmpty);
      expect(shadows.first, isA<BoxShadow>());
    });

    test('softShadow returns a list of BoxShadow', () {
      final shadows = AppColors.softShadow;
      expect(shadows, isNotEmpty);
      expect(shadows.first, isA<BoxShadow>());
    });

    test('primaryGradient has correct colors', () {
      expect(AppColors.primaryGradient.colors,
          equals([AppColors.primary, AppColors.primaryDark]));
    });
  });
}
