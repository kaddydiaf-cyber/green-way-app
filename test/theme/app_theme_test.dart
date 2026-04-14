import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_way_new/theme/app_theme.dart';
import 'package:green_way_new/theme/app_colors.dart';

void main() {
  group('AppTheme - Light', () {
    final theme = AppTheme.lightTheme;

    test('uses Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('has light brightness', () {
      expect(theme.brightness, equals(Brightness.light));
    });

    test('primary color is AppColors.primary', () {
      expect(theme.colorScheme.primary, equals(AppColors.primary));
    });

    test('scaffold background is light', () {
      expect(theme.scaffoldBackgroundColor, equals(AppColors.backgroundLight));
    });

    test('appBar uses primary color', () {
      expect(theme.appBarTheme.backgroundColor, equals(AppColors.primary));
      expect(theme.appBarTheme.foregroundColor, equals(Colors.white));
    });

    test('elevated button uses primary color', () {
      final style = theme.elevatedButtonTheme.style!;
      final bgColor = style.backgroundColor!.resolve({});
      expect(bgColor, equals(AppColors.primary));
    });

    test('card uses light surface color', () {
      expect(theme.cardTheme.color, equals(AppColors.surfaceLight));
    });

    test('bottom navigation bar uses white background', () {
      expect(theme.bottomNavigationBarTheme.backgroundColor, equals(Colors.white));
      expect(theme.bottomNavigationBarTheme.selectedItemColor, equals(AppColors.primary));
    });

    test('FAB uses primary color', () {
      expect(theme.floatingActionButtonTheme.backgroundColor, equals(AppColors.primary));
      expect(theme.floatingActionButtonTheme.foregroundColor, equals(Colors.white));
    });
  });

  group('AppTheme - Dark', () {
    final theme = AppTheme.darkTheme;

    test('uses Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('has dark brightness', () {
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('primary color is AppColors.primary', () {
      expect(theme.colorScheme.primary, equals(AppColors.primary));
    });

    test('scaffold background is dark', () {
      expect(theme.scaffoldBackgroundColor, equals(AppColors.backgroundDark));
    });

    test('card uses dark card color', () {
      expect(theme.cardTheme.color, equals(AppColors.cardDark));
    });

    test('dialog uses dark surface color', () {
      expect(theme.dialogTheme.backgroundColor, equals(AppColors.surfaceDark));
    });
  });

  group('AppTheme - Common Decorations', () {
    test('headerDecoration uses primary gradient', () {
      expect(AppTheme.headerDecoration.gradient, equals(AppColors.primaryGradient));
    });

    testWidgets('cardDecoration returns light colors in light theme', (tester) async {
      late BoxDecoration decoration;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              decoration = AppTheme.cardDecoration(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(decoration.color, equals(AppColors.surfaceLight));
      expect(decoration.boxShadow, isNotEmpty);
    });

    testWidgets('cardDecoration returns dark colors in dark theme', (tester) async {
      late BoxDecoration decoration;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              decoration = AppTheme.cardDecoration(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(decoration.color, equals(AppColors.cardDark));
      expect(decoration.boxShadow, isEmpty);
    });
  });
}
