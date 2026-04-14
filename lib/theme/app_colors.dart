import 'package:flutter/material.dart';

class AppColors {
  // ==================== Brand Colors ====================
  static const primary = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFFC8E6C9);

  // ==================== Semantic Colors ====================
  static const error = Colors.red;
  static const warning = Colors.orange;
  static const info = Colors.blue;
  static const success = Colors.green;

  // ==================== Status Colors ====================
  static const statusPending = Colors.orange;
  static const statusAccepted = Colors.blue;
  static const statusCompleted = Colors.green;
  static const statusCancelled = Colors.red;
  static const statusSold = Colors.teal;

  // ==================== Role Colors ====================
  static const roleCitizen = Colors.blue;
  static const roleCollector = Colors.purple;
  static const roleCollectionPoint = Colors.orange;
  static const roleFactory = Colors.teal;
  static const roleAdmin = Colors.red;

  // ==================== Waste Type Colors ====================
  static const wastePlastic = Colors.blue;
  static const wastePaper = Colors.brown;
  static const wasteGlass = Colors.green;
  static const wasteMetal = Colors.grey;
  static const wasteElectronics = Colors.purple;
  static const wasteOrganic = Colors.lightGreen;
  static const wasteWood = Color(0xFF8D6E63);
  static const wasteOther = Colors.blueGrey;

  // ==================== Light Theme ====================
  static const backgroundLight = Color(0xFFF5F5F5);
  static const surfaceLight = Colors.white;
  static const onSurfaceLight = Color(0xFF212121);
  static const subtextLight = Color(0xFF757575);

  // ==================== Dark Theme ====================
  static const backgroundDark = Color(0xFF121212);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const cardDark = Color(0xFF2C2C2C);
  static const onSurfaceDark = Color(0xFFE0E0E0);
  static const subtextDark = Color(0xFFB0B0B0);

  // ==================== Gradients ====================
  static const primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== Tints ====================
  static Color primaryTint([int alpha = 30]) => primary.withAlpha(alpha);
  static Color errorTint([int alpha = 30]) => error.withAlpha(alpha);
  static Color warningTint([int alpha = 30]) => warning.withAlpha(alpha);
  static Color infoTint([int alpha = 30]) => info.withAlpha(alpha);

  // ==================== Shadows ====================
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.grey.withAlpha(25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.grey.withAlpha(15),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
