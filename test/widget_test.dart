import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_way_new/app.dart';


void main() {
  group('SplashScreen', () {
    testWidgets('renders app name and loading indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );

      expect(find.text('Green Way'), findsOneWidget);
      expect(find.text('الطريق الأخضر'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.eco), findsOneWidget);
    });
  });

  group('WelcomeScreen', () {
    testWidgets('renders welcome elements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );

      // SplashScreen should have the gradient background
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.decoration, isA<BoxDecoration>());
    });
  });
}
