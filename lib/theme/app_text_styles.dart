import 'package:flutter/material.dart';

class AppTextStyles {
  // ==================== Headers (on green backgrounds) ====================
  static const headerTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const headerSubtitle = TextStyle(
    fontSize: 14,
    color: Colors.white70,
  );

  // ==================== Section Titles ====================
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const sectionSubtitle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  // ==================== Card Content ====================
  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const cardSubtitle = TextStyle(
    fontSize: 13,
    color: Colors.grey,
  );

  static const cardBody = TextStyle(
    fontSize: 14,
  );

  // ==================== Stats ====================
  static TextStyle statValue(Color color) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: color,
  );

  static TextStyle statLabel(Color color) => TextStyle(
    fontSize: 13,
    color: color,
  );

  // ==================== Buttons ====================
  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const buttonTextSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ==================== Labels & Captions ====================
  static const label = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static const caption = TextStyle(
    fontSize: 11,
    color: Colors.grey,
  );

  static TextStyle badge(Color color) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: color,
  );
}
